#encoding:utf-8
from setuptools import setup, find_packages
import sys, os
import re
import time

with open('README', 'rb') as f:
    readme = f.read().decode('utf-8')

install_requires = []
with open('requirements.txt', 'rb') as f:
    for req in f.readlines():
    	install_requires.append(req.strip())

setup(
    name='TestPaste',	#包名
    version='0.0.1',	#版本信息
    description='persons_tools',
    long_description=readme,
    author='xxx',
    author_email='xxx@xxx.com',
    install_requires=install_requires,	# 安装依赖的其他包
    package_dir={"":"."},
    py_modules=["calculator", "paste1", "logFilter", "__init__"],
    packages= find_packages(exclude=['ez_setup', 'examples', 'tests']),	#要(include)打包（exclude不要打包）的项目文件夹
    #data_files=[('config',["config.ini"])],
    data_files = [('', ['config.ini'])],
    package_data = {
        '':['config.ini']
    },
    scripts=["script/echo.sh"],
    zip_safe=False,	# 设定项目包为不安全，需要每次都检测其安全性
    include_package_data=True,	# 自动打包文件夹内所有数据
)
