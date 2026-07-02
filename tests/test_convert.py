import runpy
import subprocess
import sys
from pathlib import Path
from unittest.mock import patch

import pytest

from comet2txt import convert_data, convert_file, convert_line, main

TESTS_DIR = Path(__file__).parent


# ---------------------------------------------------------------------------
# Unit tests

@pytest.mark.parametrize("stem", ["comet", "test"])
def test_convert_file_matches_expected(stem):
    source = TESTS_DIR / f"{stem}.S"
    expected_lines = (TESTS_DIR / f"{stem}.asm").read_text(encoding="ascii").splitlines()
    assert convert_file(str(source)) == expected_lines


# ---------------------------------------------------------------------------
# End-to-end CLI tests

def run_cli(*args):
    """Run the comet2txt CLI via the installed entry point module."""
    return subprocess.run(
        [sys.executable, "-m", "comet2txt", *args],
        capture_output=True,
        text=True,
    )

@pytest.mark.parametrize("stem", ["comet", "test"])
def test_cli_stdout(stem):
    """CLI without an output file prints converted lines to stdout."""
    source = TESTS_DIR / f"{stem}.S"
    expected = (TESTS_DIR / f"{stem}.asm").read_text(encoding="ascii")
    result = run_cli(str(source))
    assert result.returncode == 0
    assert result.stdout == expected

@pytest.mark.parametrize("stem", ["comet", "test"])
def test_cli_file_output(tmp_path, stem):
    """CLI with an output file writes converted lines to that file."""
    source = TESTS_DIR / f"{stem}.S"
    expected = (TESTS_DIR / f"{stem}.asm").read_text(encoding="ascii")
    out_file = tmp_path / f"{stem}.asm"
    result = run_cli(str(source), str(out_file))
    assert result.returncode == 0
    assert out_file.read_text(encoding="ascii") == expected

def test_cli_missing_input_exits_nonzero():
    """CLI exits with a non-zero code when the input file does not exist."""
    result = run_cli("nonexistent.S")
    assert result.returncode != 0
    assert result.stderr  # some error message on stderr


# ---------------------------------------------------------------------------
# convert_line edge-case unit tests

def test_convert_line_missing_null_terminator():
    """Exhausting data before the null terminator raises ValueError."""
    # b'A' is printable ASCII so it is consumed, then data is empty on the
    # next iteration which triggers the guard.
    with pytest.raises(ValueError, match="line missing null terminator"):
        convert_line(b"A")

def test_convert_line_unknown_token_silent():
    """An unknown token byte (0x0F) exits the loop silently when quiet=True."""
    # 0x0F: > max_label_len (14), < 0x20 (not printable), < 0x80 (not a token)
    result = convert_line(b"\x0f\x00")
    assert result == ""

def test_convert_line_unknown_token_not_quiet(capsys):
    """An unknown token byte emits a warning to stderr when quiet=False."""
    convert_line(b"\x0f\x00", quiet=False)
    captured = capsys.readouterr()
    assert "0F" in captured.err

def test_convert_line_data_after_line_end_not_quiet(capsys):
    """Bytes remaining after the null terminator are reported to stderr when quiet=False."""
    # The null terminator is consumed first, leaving b'extra' in data.
    convert_line(b"\x00extra", quiet=False)
    captured = capsys.readouterr()
    assert "data after line end" in captured.err


# ---------------------------------------------------------------------------
# convert_data error-path unit tests

def test_convert_data_bad_start():
    """convert_data raises ValueError when the file does not begin with 0x00."""
    with pytest.raises(ValueError, match="unexpected file start"):
        convert_data(b"\xff\x00")

def test_convert_data_bad_end():
    """convert_data raises ValueError when the file does not end correctly."""
    # A file with only the mandatory start byte has no end-of-lines sentinel.
    with pytest.raises(ValueError, match="unexpected file end"):
        convert_data(b"\x00")


# ---------------------------------------------------------------------------
# main() in-process tests for command-line arguments.

def test_main_stdout(capsys):
    """main() prints converted lines to stdout when no output file is provided."""
    source = TESTS_DIR / "test.S"
    expected = (TESTS_DIR / "test.asm").read_text(encoding="ascii")
    with patch("sys.argv", ["comet2txt", str(source)]):
        main()
    assert capsys.readouterr().out == expected

def test_main_file_output(tmp_path):
    """main() writes converted lines to a file when an output path is provided."""
    source = TESTS_DIR / "test.S"
    expected = (TESTS_DIR / "test.asm").read_text(encoding="ascii")
    out_file = tmp_path / "out.asm"
    with patch("sys.argv", ["comet2txt", str(source), str(out_file)]):
        main()
    assert out_file.read_text(encoding="ascii") == expected

def test_main_missing_input_exits(capsys):
    """main() exits with code 1 and writes an error to stderr for a missing input file."""
    with patch("sys.argv", ["comet2txt", "nonexistent.S"]):
        with pytest.raises(SystemExit) as exc_info:
            main()
    assert exc_info.value.code == 1
    assert capsys.readouterr().err


# ---------------------------------------------------------------------------
# __main__.py coverage via runpy

def test_dunder_main_entrypoint(capsys):
    """Importing the package as __main__ (i.e. python -m comet2txt) runs main()."""
    source = TESTS_DIR / "test.S"
    expected = (TESTS_DIR / "test.asm").read_text(encoding="ascii")
    with patch("sys.argv", ["comet2txt", str(source)]):
        runpy.run_module("comet2txt", run_name="__main__", alter_sys=True)
    assert capsys.readouterr().out == expected


def test_comet2txt_script_guard(capsys):
    """Executing comet2txt.py directly triggers the if __name__ == '__main__' guard."""
    source = TESTS_DIR / "test.S"
    expected = (TESTS_DIR / "test.asm").read_text(encoding="ascii")
    script = Path(__file__).parent.parent / "src" / "comet2txt" / "comet2txt.py"
    with patch("sys.argv", ["comet2txt.py", str(source)]):
        runpy.run_path(str(script), run_name="__main__")
    assert capsys.readouterr().out == expected

def test_main_package_not_found(capsys):
    """main() falls back to 'unknown' version when the package is not installed."""
    from importlib.metadata import PackageNotFoundError
    source = TESTS_DIR / "test.S"
    with patch("comet2txt.comet2txt.version", side_effect=PackageNotFoundError):
        with patch("sys.argv", ["comet2txt", str(source)]):
            main()
    assert capsys.readouterr().out  # conversion still succeeds
