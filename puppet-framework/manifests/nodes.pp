# DEVAPP: Puppet Nodes
# 
#
node 'hostdevapp01.scoday.com' inherits devapp-webserver {}
node 'hostdevapp02.scoday.com' inherits devapp-webserver {}
node 'hostdevapp03.scoday.com' inherits devapp-webserver {}
node 'hostdevapp04.scoday.com' inherits devapp-webserver {
    include splunk-eai
}

# DBSERVER  Server Systems:
# Database servers currently unmanaged by puppet 11APR2011 #
#node 'hostdevdb01.scoday.com' inherits basenode-dbserver {}
#node 'hostdevdb02.scoday.com' inherits basenode-dbserver {}

# Jira Serer going to add to basenode 08JUN2011 #
#node 'hostdvjira01.scoday.com' inherits basenode-jiraserver {}

