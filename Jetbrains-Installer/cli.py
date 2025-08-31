#!/usr/bin/env python
import re
import platform
import os
import sys
import subprocess
import json
import getpass

def checkArm():
    if platform.machine() == "aarch64":
        return True
    else:
        return False


# 读取命令行参数，获取 json 文件路径
if len(sys.argv) > 1 and sys.argv[1].endswith('.json'):
    fileName = sys.argv[1]
    arg_offset = 1
else:
    fileName = "./listing.json"  # 默认文件
    arg_offset = 0

package_versions = {}
args_to_remove = []
for i, arg in enumerate(sys.argv):
    if arg.startswith("--"):
        pkg = arg[2:].replace("-", "_").lower()
        # 下一个参数为版本号
        if i + 1 < len(sys.argv) and not sys.argv[i + 1].startswith("--"):
            package_versions[pkg] = sys.argv[i + 1]
            args_to_remove.extend([arg, sys.argv[i + 1]])
        else:
            print(f"Warning: No version specified for {arg}")
            args_to_remove.append(arg)

# 移除已处理的参数
for arg in args_to_remove:
    if arg in sys.argv:
        sys.argv.remove(arg)

listingFile = open(fileName, "r")
productListing = json.loads(listingFile.read())
productNameMap = {k.lower(): k for k in productListing.keys()}
supportedProducts = list(productNameMap.keys())
listingFile.close()

# fileName = "./listing.json"
# if checkArm():
#     fileName = "./listing-arm.json"
# listingFile = open(fileName, "r")
InstallPath = "/SunshineCloud/Jetbrains/"
TEMPPath = "/SunshineCloud/Jetbrains/temp"
User = getpass.getuser()
# productListing = json.loads(listingFile.read())
# productNameMap = {k.lower(): k for k in productListing.keys()}
# supportedProducts = list(productNameMap.keys())

# listingFile.close()

#unsupportedProducts = ['aqua']

# print(supportedProducts)

def safeSearch(array, value):
    try:
        return array.index(value)
    except ValueError:
        return -1

def verifyProduct(productName):
    if safeSearch(supportedProducts, productName.lower()) != -1:
        return True
    else:
        print("Product does not exist")
        return False

# 默认版本号
default_version = "2024.1.4"

# def getProductDownloadLink(productName):
#     if verifyProduct(productName):
#         # 用映射找到原始产品名
#         originalName = productNameMap[productName.lower()]
#         url = productListing[originalName]
#         return url, originalName
#     else:
#         return "about:blank", None

def getProductDownloadLink(productName):
    if verifyProduct(productName):
        originalName = productNameMap[productName.lower()]
        url = productListing[originalName]
        # 获取包名 key（与 package_versions 的 key 对应）
        pkg_key = originalName.replace("-", "_").lower()
        # 获取该包的版本号，没有则用默认
        version = package_versions.get(pkg_key, default_version)
        url = url.replace("${version}", version)
        return url, originalName
    else:
        return "about:blank", None

def installLinuxArchive(productName, archivepath):
    ceNum = 0

    return subprocess.run(["sudo", "/usr/bin/env", "bash", "software_install.sh", archivepath, productName, InstallPath, TEMPPath, User, str(ceNum)]).returncode


def urlretrieve(url, filename):
    return subprocess.run(["wget", "-O", filename, url]).returncode == 0


def getProductList(arguments):
    productList = []
    if safeSearch(arguments, "@all") != -1:
        productList = supportedProducts
    if safeSearch(arguments, "@pro") != -1:
        for product in supportedProducts:
            if (not product.endswith("-ce")) and (safeSearch(productList, product) == -1):
                productList = productList + [product]
    if safeSearch(arguments, "@ce") != -1:
        for product in supportedProducts:
            if (product.endswith("-ce")) and (safeSearch(productList, product) == -1):
                productList = productList + [product]
    for x in range(1, len(arguments)):
        if (safeSearch(productList, arguments[x].lower()) == -1) and (not arguments[x].lower().startswith("@")):
            productList = productList + [arguments[x].lower()]
    #print(productList)
    return productList

def installProduct(productName):
    url, originalName = getProductDownloadLink(productName)
    print("URL: " + url + "")
    tarF = "./"+originalName+".tar.gz"
    if url != "about:blank":
        if urlretrieve(url, tarF):
            print("Installing " + originalName)
            if installLinuxArchive(originalName, tarF) == 0:
                os.remove(tarF)
        else:
            print("Download Failed!")

def interactive():
    print("JetBrains Installer Interactive")
    print("ls to list supported products, quit to leave interactive")
    if checkArm():
        print("Processor: ARM64")
    else:
        print("Processor: x86_64")

    test = ""
    while test != "quit":
        test = input("Enter JetBrains Product Name: ")
        if test == "quit":
            break
        if (test != "ls") and (verifyProduct(test)):
            installProduct(test)
        elif test == "ls":
            printListing()


def printListing():
    print("Supported Products: ")
    for product in supportedProducts:
        print(product)
    print()
    #print("Unsupported Product: ")
    #print("aqua - IDE in beta, doesn't support ARM Linux")


args = list(sys.argv)
# #print(len(args))

# args = sys.argv[arg_offset+1:]
# if len(args) == 0:
#     args = ['-h']
if len(args) == 1:
    args = args + ['-h']
if args[1] == "-h":
    print("Syntax: cli.py [-hli] [-e PATH_TO_ARCHIVE] PRODUCT(s) [-c]")
elif args[1] == "-l":
    printListing()
elif args[1] == "-i":
    interactive()
elif args[1] == "-e":
    if len(args) == 4:
        args = args + [""]
    if len(args) == 5:
        if verifyProduct(args[3]):
            installLinuxArchive(args[3], args[2].lower())
    else:
        print("Invalid Arguments")
else:
    for product in getProductList(args):
        if verifyProduct(product):
            #print(product)
            installProduct(product)