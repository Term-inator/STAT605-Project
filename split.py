import gzip
import os

def copy_json_lines_to_compressed_files(input_file, output_dir, lines_per_file):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    buffer = []
    file_count = 0
    line_count = 0
    
    with gzip.open(input_file, 'rt', encoding='utf-8') as f:
        for line in f:
            buffer.append(line)
            line_count += 1
            if line_count % 100000 == 0:
                print(line_count)
            if len(buffer) >= lines_per_file:
                file_count += 1
                output_file = os.path.join(output_dir, f'json_{file_count}.json.gz')
                print(output_file)
                with gzip.open(output_file, 'wt', encoding='utf-8') as out_f:
                    out_f.writelines(buffer)
                buffer = []
                print("ok")

        if buffer:
            file_count += 1
            output_file = os.path.join(output_dir, f'json_{file_count}.json.gz')
            with gzip.open(output_file, 'wt', encoding='utf-8') as out_f:
                out_f.writelines(buffer)
                
    print("done.")


name = 'Video_Games'
input_file = f'data/{name}.json.gz'
output_dir = f'data/{name}/'
lines_per_file = 400000

copy_json_lines_to_compressed_files(input_file, output_dir, lines_per_file)
