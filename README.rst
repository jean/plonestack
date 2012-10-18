==========
plonestack
==========

.. image:: https://travis-ci.org/isotoma/plonestack.png
   :target: https://travis-ci.org/#!/isotoma/plonestack

At Isotoma towers we have settled around a fairly standard buildout for
deploying Plone.

Inititally we copied and pasted this still evolving buildout between projects.
Backporting fixes to other sites was tedious, time consuming and error prone.
We switched to having the buildout on a HTTP server. However the lack of basic
auth support in buildout made this problematic for us. So we made "stacks" - a
special kind of buildout extension which allowed us to package our standard
buildout as eggs.

This is a 'stack' for deploying Plone on Ubuntu and Red Hat boxes.


Why exactly?
============

We like our website estate to be maintainable. Part of that is if we vastly
improve our operational capability we want that capability to be available for
all our sites.

Copy-pasting updates into buildout.cfg's accross multiple sites was too error
prone and it was difficult to say with certainty which sites had which
capabilities. Now we can site "that site has version X of plonestack".

You could achieve the same with a static web server and HTTP references in your
``${buildout:extends}``. But eggs make it easier to ship support scripts,
templates and odds and ends. It means we can use the same workflow and tools
(like zest.releaser) that we do for the rest of our code.


Getting started
===============

Your buildout now looks like this::

    [buildout]
    extensions = plonestack
    versions = versions

    [versions]
    zc.buildout = 1.4.3
    Plone = 4.2.1


The stack
=========

By default we run Apache, Varnish, Pound, Zope and ZEO. Apache is used as an
SSL terminator. Often we use it as the basic auth provider. We run a varnish
instance and a pound instance for each site rather than trying to share a
single instance for the whole box.


Plone
=====

The version of Plone is controlled through the ``${versions:Plone}`` variable.
The corresponding versions file will be loaded from the plonestack config.
For pre-egg zope plone.recipe.distros will be used automatically.

A migration script will be created at ``bin/migrate``. This will also be run
during buildout. It will install products and run GenericSetup profiles.

It can also set portal properties and call setters on objects::

    [migrate:mutators]
    portal_cache_settings.setEnabled = True
    portal_cache_settings.setDomains =
        http://example.org/
        https://example.org/

    [migrate:properties]
    mybool = true
    myproperty = dog
    mylist =
        foo
        bar
        baz

Using these may lead to scornful looks, however.

If the ``bin/migrate`` script detects any mountpoints inside the Plone site it is updating that are being blocked by objects in the main Data.fs then those objects will automatically be migrated into the mountpoint. This facilitates moving to a split catalog setup to improve your catalog performance.

Incidentally, there is a feature flag for split catalog::

    [plonestack]
    extras = enable-split-portal-catalog

The next time you run buildout you will have a split site.

Developer builds of your code will have a ``bin/test``. By default it will run the tests of any develop eggs it can detect in your checkout.


Zope
====

Our zope build is pretty standard.

A suitable version of Zope is chosen automatically based on your Plone version,
however this can be overidden by setting ``${versions:Zope2}``. Where needed
the zope2install recipe will automatically be used.

The number of zopes is variable. By default you get 3. You can scale that up or
down by setting ${environment:numzopes}::

    [environment]
    numzopes = 9

With that plonestack will create you new zope instances. Pound, filestorage,
fss and anything else sensitive to the number of the zopes will be adjust as
well.

All installs will have a ``zopeU`` instance for running scripts against.

The buildout knows the subversion branch/tag or git branch that it is being deployed from. We bake that information into zope.conf.


Pound
=====

By default we use a system installed pound. We run an new instance of that pound with its own start/stop script and config file for each buildout.

By default our pound config will give you sticky sessions based on the
``_ZopeId`` cookie. This means that users will tend to get the same zope. This
is better for your cache and avoids session management issues.

One of the advantages of using a load balancer is that you can take a backend
out of use before restarting it. The other backends remain in service so users
don't experience downtime. So we have a cycle script to automate this kind of a
restart. It will:

 * Take a backend out of the load balancer
 * Wait until all connections to it are complete (by inspecting
   ``/proc/net/tcp``). Pound has a timeout so they will all eventually by
   terminated.
 * Stop zope
 * Start zope
 * Wait for the instance to appear as LISTEN (again in ``/proc/net/tcp``)
 * Wake the instance (by hitting preset urls directly)
 * Put the backend back into active use in the load balancer

You can turn off pound with a feature flag::

    [plonestack]
    extras =
        nopound


Varnish
=======

By default we use a system installed varnish. We run an new instance of that varnish with its own start/stop script and VCL file for each buildout.

Our standard varnish recipe supports testing your VCL before attempting to use
it::

    ./bin/varnishtool configtest

And obviously you'll want to be able to reload your VCL without downtime. So we
provide a wrapper for that too::

    ./bin/varnishtool graceful


Apache
======

This is the only part of the stack that might be shared by multiple sites.
Buildout will generate apache config files that can be symlinked into
``/etc/apache2/sites-available``.

Apache default VHost behaviour can mean that even if your config is wrong enough that the IP's aren't even right it can still seem to be working. Months later installing another site can change the default and suddenly a site you thought was
working no longer is. Our apache configs set a header of ``sitename`` on their responses. This can be used by your monitoring system to make sure the VHost you expect to reply is the one that is replying.


Environment adaptability
========================

By default this buildout can be deployed as any user. When it is started it will try and run as that user. This behaviour is controlled by ``${environment:effective-user}``.

It is optimized for servers with multiple IP addresses. By default it will try and use the IP address of ``eth0``. You can override that behaviour::

    [hosts]
    apache = 10.33.33.3
    zope = 10.33.33.4

