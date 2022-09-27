#! /bin/sh
# 명령 실패 시 즉시 script 종료
# 명령어의 리턴 코드가 0이 아니면 실패라고 간주하고 실행 종료 (https://118k.tistory.com/201)
set -e
# <<-EOSQL END OF SQL SQL문이 끝났다는 명시적 표현
# 복사 할 사용자 추가
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
CREATE USER ${REPLICA_USER} REPLICATION LOGIN ENCRYPTED PASSWORD '${REPLICA_USER_PASSWORD}';
EOSQL

# 복제 슬롯 생성
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
SELECT * FROM pg_create_physical_replication_slot('${REPLICATION_SLOT}');
EOSQL

# mkdir $PGDATA/archive

# http://kimchki.blogspot.com/2019/09/postgresql-replication.html

# postgresql.conf
# wal_level : 아래 3개 중 택 1
# - minimal: 충돌 또는 즉시 셧다운으로부터 복구하기 위해 필요한 정보만 기록
# - replica: WAL 아카이브에 필요한 로깅과 대기 서버에서 읽기 전용 쿼리에 필요한 정보를 추가
# - logical: 논리적 디코딩을 지원하는 데 필요한 정보를 추가
# max_wal_senders: WAL 파일을 전송할 수 있는 최대 서버수
# wal_keep_size(wal_keep_segments):  보관할 WAL 파일의 수
# listen_addresses: 접속을 허용할 IP

cat >> "$PGDATA/postgresql.conf" <<EOF
wal_level = replica
max_wal_senders = 3
wal_keep_size = 32
listen_addresses = '*'
EOF


# pg_hba.conf
cat >> "$PGDATA/pg_hba.conf" <<EOF
host replication ${REPLICA_USER} 0.0.0.0/0 md5
EOF