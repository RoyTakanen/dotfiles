# aliases & functions
alias docker-compose="docker compose"
alias bashrc-edit="vim ~/.bashrc && source ~/.bashrc"
alias btop="btop -lc"

# These are dependant on the system configuration (only work on protokolla.fi servers)
alias acme.sh='docker compose -f /opt/services/acme.sh/docker-compose.yml exec acme acme.sh'
alias nginx='docker-compose -f /opt/services/nginx/docker-compose.yml exec nginx nginx'

# nginx scripts
nginx-reload() {
   nginx -t && nginx -s reload
}

nginx-enable() {
   [ -z "$1" ] && echo "usage: nginx-enable <name>" && return
   cd /opt/services/nginx/sites-enabled
   ln -s ../sites-available/$1.conf /opt/services/nginx/sites-enabled/$1.conf
   cd -
}

nginx-new() {
   [ -z "$1" ] && echo "usage: nginx-new <template> <name> <port> <hostname>" && return
   cp /opt/services/nginx/templates/$1 /opt/services/nginx/sites-available/$2.conf
   sed -i "s/SERVICE_PORT/$3/" /opt/services/nginx/sites-available/$2.conf && sed -i "s/SERVER_NAME/$4/" /opt/services/nginx/sites-available/$2.conf
   $EDITOR /opt/services/nginx/sites-available/$2.conf
}

# acme.sh scripts

certificates='/opt/services/acme.sh/certs'

gen-wild-ssl() {
   domain="$1"
   [ -z "$domain" ] && echo "usage: gen-wild-ssl <domain>" && return
   acme.sh --issue --dns dns_pdns -d $domain -d *.$domain
   mkdir -p $certificates/$domain
   acme.sh --install-cert --domain $domain --fullchain-file /certs/$domain/full.pem --key-file /certs/$domain/key.pem
}

# service scripts

stop-all-services() {
   cd /opt/services
   for d in */ ; do
      cd "$d"
      docker-compose down
      cd -
   done
}

start-all-services() {
   cd /opt/services
   for d in */ ; do
      cd "$d"
      docker-compose up -d
      cd -
   done
}

# ---------
# VARIABLES
# ---------

IP=$(curl -4 -s ip.antti.codes)
PATH="/usr/local/bin:$PATH"
EDITOR="vim"
# I really like this, will probably use in the future with desktops and the other one with servers
# PS1="\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]"
PS1='\n\[\e[38;5;197;1m\]\u\[\e[0m\]@\[\e[2;3m\]\H \[\e[23m\](\[\e[0;3m\]$(w --no-header|wc -l) users\[\e[0;2m\]) \[\e[0;38;5;150m\][$IP] \[\e[38;5;117m\]\w \[\e[0m\]\$ '

# Save bash history after every command
export PROMPT_COMMAND='history -a'
