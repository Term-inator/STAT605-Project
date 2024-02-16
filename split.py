import gzip
import os

def copy_json_lines_to_compressed_files(input_file, output_dir, lines_per_file):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    buffer = []  # 初始化缓冲区
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
                buffer = []  # 清空缓冲区
                print("ok")

        # 处理剩余的行
        if buffer:
            file_count += 1
            output_file = os.path.join(output_dir, f'json_{file_count}.json.gz')
            with gzip.open(output_file, 'wt', encoding='utf-8') as out_f:
                out_f.writelines(buffer)
                
    print("done.")


# 输入和输出路径
name = 'Video_Games'
input_file = f'data/{name}.json.gz'
output_dir = f'data/{name}/'
lines_per_file = 400000

# 调用函数
copy_json_lines_to_compressed_files(input_file, output_dir, lines_per_file)
