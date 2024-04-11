import re

def mark(text, args, Mark, extra_cli_args, *a):
    for idx, m in enumerate(re.finditer(r'#\d+', text)):
        start, end = m.span()
        mark_text = text[start:end].replace('\n', '').replace('\0', '')
        yield Mark(idx, start, end, mark_text, {})

def handle_result(args, data, target_window_id, boss, extra_cli_args, *a):
    number = data['match'][0][1:]
    boss.open_url(f'https://www.github.com/bemlo/bemlo/pull/{number}')
