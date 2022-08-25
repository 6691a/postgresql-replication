#! /bin/sh

# 명령 실패 시 즉시 script 종료
# 명령어의 리턴 코드가 0이 아니면 실패라고 간주하고 실행 종료 (https://118k.tistory.com/201)
set -e
# <<-EOSQL END OF SQL SQL문이 끝났다는 명시적 표현
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB"<<-EOSQL
CREATE USER ${REPLICA_USER} REPLICATION LOGIN ENCRYPTED PASSWORD '${REPLICA_USER_PASSWORD}';
EOSQL

mkdir $PGDATA/archive

# postgresql.conf
# 정의 참조
# http://kimchki.blogspot.com/2019/09/postgresql-replication.html
# https://postgresql.kr/docs/9.6/runtime-config-replication.html
# https://therishabh.in/setting-up-master-slave-replication-in-postgresql-using-dockers-and-external-volumes/
cat >> "$PGDATA/postgresql.conf" <<EOF
wal_level = replica
max_wal_senders = 3
wal_keep_size = 32
listen_addresses = '*'
synchronous_commit = off
EOF

# pg_hba.conf
# Localhost
# host    replication     replica          127.0.0.1/32             md5

# PostgreSQL Master IP address
# host    replication     replica          10.0.15.10/32            md5

# PostgreSQL Slave IP address
# host    replication     replica          10.0.15.11/32            md5
cat >> "$PGDATA/pg_hba.conf" <<EOF
host replication ${REPLICA_USER} 0.0.0.0/0 md5
EOF

