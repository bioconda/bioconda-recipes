def compare_binary_files(file1, file2):
    with open(file1, 'rb') as f1, open(file2, 'rb') as f2:
        content1 = f1.read()
        content2 = f2.read()

        # 输出文件内容
        print("文件1内容：")
        print(content1.hex())
        print("\n文件2内容：")
        print(content2.hex())

        # 比较文件内容
        return content1 == content2

# 示例使用
file1 = '/home/user_home/zt/bioRabbitSketch/RabbitKSSD/bacteria.sketch'
file2 = '/home/user_home/zt/bioRabbitSketch/RabbitKSSD/100.list.sketch'

if compare_binary_files(file1, file2):
    print("\n文件内容一致")
else:
    print("\n文件内容不一致")

