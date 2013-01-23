from setuptools import setup, find_packages

version = '0.1.0'

setup(
    name = 'plonestack',
    version = version,
    description = "A reusable and production ready buildout",
    url = "http://www.isotoma.com",
    classifiers = [
        "Framework :: Buildout",
        "Framework :: Buildout :: Extensions",
        "Intended Audience :: System Administrators",
        "Operating System :: POSIX",
        "License :: OSI Approved :: Apache Software License",
    ],
    keywords = "buildout",
    author = "John Carr",
    author_email = "john.carr@isotoma.com",
    license="Apache Software License",
    packages = find_packages(exclude=['ez_setup']),
    include_package_data = True,
    zip_safe = False,
    install_requires = [
        'setuptools',
        'zc.buildout',
        'missingbits >= 0.0.16',
    ],
    entry_points = {
        "zc.buildout.extension": [ "ext = plonestack:load" ],
        }
)

