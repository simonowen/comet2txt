# comet2txt.py - convert Comet assembler source code to text
#
# https://github.com/simonowen/comet2txt/

import argparse
import sys
from importlib.metadata import PackageNotFoundError, version

max_label_len = 14  # Comet hard limit
token_base = 0x80

tokens = [
    'A', 'ADC', 'ADD', 'AF', 'AND', 'B', 'BC', 'BIT', 'C', 'CALL', 'CCF', 'CP',
    'CPD', 'CPDR', 'CPI', 'CPIR', 'CPL', 'D', 'DAA', 'DE', 'DEC', 'DEFB',
    'DEFM', 'DEFS', 'DEFW', 'DI', 'DJNZ', 'DUMP', 'E', 'EI', 'EQU', 'EX', 'EXX',
    'H', 'HALT', 'HL', 'I', 'IM', 'IN', 'INC', 'IND', 'INDR', 'INI', 'INIR',
    'IX', 'IY', 'JP', 'JR', 'L', 'LD', 'LDD', 'LDDR', 'LDI', 'LDIR', 'LIST',
    'M', 'MDAT', 'NC', 'NEG', 'NOP', 'NZ', 'OFF', 'ON', 'OR', 'ORG', 'OTDR',
    'OTIR', 'OUT', 'OUTD', 'OUTI', 'P', 'PE', 'PO', 'POP', 'PUSH', 'R', 'RES',
    'RET', 'RETI', 'RETN', 'RL', 'RLA', 'RLC', 'RLCA', 'RLD', 'RR', 'RRA',
    'RRC', 'RRCA', 'RRD', 'RST', 'SBC', 'SCF', 'SET', 'SLA', 'SLL', 'SP',
    'SRA', 'SRL', 'SUB', 'XOR', 'Z']


def convert_line(data: bytes, quiet=True) -> str:
    """Convert a line of tokenised source code to text."""
    out_line = ''
    has_indent1 = has_indent2 = False

    while True:
        if len(data) == 0:
            raise ValueError("line missing null terminator")

        # End of line terminator
        if data[0] == 0:
            data = data[1:]
            break

        # Comment until end of line
        elif data[0:1] == b';':
            pad_len = data[1] - 1
            out_line += ' ' * pad_len + ';'
            out_line += data[2:-1].decode("ascii", errors="ignore")
            data = data[-1:]

        # String until next double quote
        elif data[0:1] == b'"':
            str_len = data[1:].index(b'"') + 1
            out_line += data[:str_len+1].decode("ascii", errors="ignore")
            data = data[str_len+1:]

        # Symbol
        elif data[0] <= max_label_len:
            sym_len = data[0]
            sym = data[1:sym_len + 1]
            data = data[sym_len + 1:]
            out_line += sym.decode("ascii", errors="ignore") + ':'

        # Token
        elif data[0] >= token_base and (data[0] - token_base) < len(tokens):
            if not has_indent1:
                out_line = f'{out_line:15s}'
                has_indent1 = True

            out_line += tokens[data[0] - token_base]
            data = data[1:]

            if not has_indent2:
                out_line = f'{out_line:20s}'
                has_indent2 = True

        # Printable ASCII character
        elif data[0] >= 0x20 and data[0] <= 0x7f:
            out_line += chr(data[0])
            data = data[1:]

        # Unhandled token (should be none in valid file)
        else:
            if not quiet:
                print(f"ignoring unknown token: {data[0]:02X}", file=sys.stderr)
            data = data[1:]
            break

    if len(data) > 0:
        if not quiet:
            print(f"data after line end: {data.hex()}", file=sys.stderr)

    out_line = out_line.replace('\x7f', '(c)')
    return out_line.rstrip()


def convert_data(data: bytes, quiet=True) -> list[str]:
    """Convert the content of a .S source file to a list of text lines."""
    if data[0:1] != b'\x00':
        raise ValueError("unexpected file start")
    data = data[1:]

    out_lines = []
    while len(data) > 0:
        line_len = data[0]
        line_data = data[1:line_len]
        data = data[line_len:]

        if line_len == 0:
            break

        out_lines.append(convert_line(line_data, quiet))

    if data != b'\x00':
        raise ValueError("unexpected file end")

    return out_lines


def convert_file(filename: str, quiet=True) -> list[str]:
    """Open and convert a .S source file by filename."""
    with open(filename, "rb") as f:
        data = f.read()
    return convert_data(data, quiet)


def main():
    """Main entry point for command line usage."""
    try:
        pkg_version = version('comet2txt')
    except PackageNotFoundError:
        pkg_version = 'unknown'

    parser = argparse.ArgumentParser(prog="comet2txt", description="Convert Comet assembler source to text")
    parser.add_argument("input_file", help="input .S file to convert")
    parser.add_argument("output_file", nargs="?", default='', help="output .asm file to write")
    parser.add_argument("-q", "--quiet", action="store_true", default=False, help="suppress conversion warnings")
    parser.add_argument('-V', '--version', action='version', version=f'%(prog)s {pkg_version}')
    args = parser.parse_args()

    try:
        out_lines = convert_file(args.input_file, args.quiet)

        if args.output_file:
            with open(args.output_file, "w") as f:
                for line in out_lines:
                    f.write(line + "\n")
        else:
            for line in out_lines:
                print(line)
    except Exception as e:
        print(e, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
