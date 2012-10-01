import platform

from zc.buildout import UserError

from missingbits.stack import Stack, split


def _get_version(config, package):
    version = config.get(package, None)
    if version:
        return version
    raise UserError("Please pin the version of '%s'" % package)


def load(buildout):
    config = buildout.get(__name__, {})

    s = Stack("plonestack", buildout)
    s.load("versions.cfg")
    s.load("base.cfg")

    if config.get("environment", "dev") != "dev":
        s.load("fullstack.cfg")
        s.load("environment/%s/environment.cfg" % config['environment'])
    else:
        s.load("dev.cfg")

    versions_section = s.peek("buildout", "versions")
    plone_version = s.peek(versions_section, "Plone")

    plone_config = "plone/plone-%s.cfg" % plone_version

    # Assumes that versions_section is still set correctly from previous
    # step.
    try:
        zope_version = s.peek(versions_section, "Zope2")
    except UserError:
        zope_version = s.peek_unloaded(plone_config, versions_section, "Zope2")

    zope_config = "zope/zope-%s.cfg" % zope_version

    # Actually load the zope and plone configuration
    s.load(zope_config)
    s.load(plone_config)

    # Load any Ubuntu or Red Hat specific configuration
    try:
        distname, version, distid = platform.linux_distribution()
    except AttributeError:
        distname, version, distid = platform.dist()

    s.load("platform/%s.cfg" % distname, optional=True)
    s.load("platform/%s_%s.cfg" % (distname, distid), optional=True)

    for extra in split(config.get("extras", "")):
        s.load("extras/" + extra + ".cfg")
        if config.get("environment", "dev") != "dev":
            s.load("extras/" + extra + "_fullstack.cfg", optional=True)

    s.apply()

