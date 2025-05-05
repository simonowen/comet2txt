# comet2txt.py v1.0 - Convert Comet assembler source code to text
#
# https://github.com/simonowen/comet2txt/

import sys
import argparse

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


# Parse a line of tokenised source code.
def parse_line(data):
    out_line = ''
    has_indent1 = has_indent2 = False

    while True:
        if len(data) == 0:
            print("Line missing null terminator", file=sys.stderr)
            break

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
            print(f"Ignoring unknown token: {data[0]:02X}", file=sys.stderr)
            data = data[1:]
            break

    if len(data) > 0:
        print(f"Data after line end: {data.hex()}", file=sys.stderr)

    return out_line.rstrip()


# Parse the content of .S source file.
def parse_file(data):
    if data[0:1] != b'\x00':
        print("Unexpected file start", file=sys.stderr)
        return []
    data = data[1:]

    out_lines = []
    while len(data) > 0:
        line_len = data[0]
        line_data = data[1:line_len]
        data = data[line_len:]

        if line_len == 0:
            break

        out_lines.append(parse_line(line_data))

    if data != b'\x00':
        print("Unexpected file end", file=sys.stderr)

    return out_lines


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert Comet assembler source to text")
    parser.add_argument("input_file", help="Input .S file to convert")
    parser.add_argument("output_file", nargs="?", default='', help="Output .asm file to write")
    args = parser.parse_args()

    with open(args.input_file, "rb") as f:
        input_data = f.read()

    out_lines = parse_file(input_data)

    if args.output_file:
        with open(args.output_file, "w") as f:
            for line in out_lines:
                f.write(line + "\n")
    else:
        for line in out_lines:
            print(line)
