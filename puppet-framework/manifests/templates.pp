################################################
# Attempting to split basenodes for different  #
# systems.                                     #
# 08 JUN 2011                                  #
################################################

# Generic Basenode for any node #
node basenode {
    include devapp-puppet
#    include devapp-group
    include devapp-hosts
    include devapp-UTC
    include devapp-sudo
    include devapp-profile
    include devapp-logins
    include devapp-fstab
    include devapp-splunk
    include httpd-svc
}

# Non-Application Server Basenode #
node basenode-jiraserver {
    include devapp-puppet
    include devapp-groupjira
    include devapp-hosts
    include devapp-UTC
    include devapp-sudojira
    include devapp-profile
    include devapp-logins
    include devapp-fstabjira
}

# Database Server Basenode #
node basenode-dbserver {
    include devapp-group-dba
    include devapp-puppet
    include devapp-hosts-db
    include devapp-UTC
    include devapp-sudo
    include devapp-profile
    include devapp-logins
    include devapp-fstab
}

# Use a simple node definition to make the
# inherit in nodes.pp cleaner
node dev-basenode inherits basenode {}

# Define what a webserver needs #
node devapp-webserver inherits basenode {
    include devapp-httpd
    include devapp-joomlacfg
    include devapp-mintdb
    include devapp-phpini
}

node devapp-jira inherits basenode-nonappserver {}
