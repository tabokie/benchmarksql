if [ $# -lt 1 ] ; then
    echo "usage: $(basename $0) WAREHOUSES MODE" >&2
    exit 2
fi

OUTPUT_SQL=tableCreates.sql

# mode=0(classic), 1(non-clustered), 2(hybrid)
if [ $# -eq 2 ] ; then
  declare -i Mode=$2
else
  declare -i Mode=0
fi

if [ $Mode -eq 2 ] ; then
  echo "Hybrid"
fi

if [ $Mode -eq 1 ] ; then
  echo "Plain"
fi

if [ $Mode -eq 0 ] ; then
  echo "Classics"
fi

declare -i nWarehouse=$1
## cardinality:
# district = 10x warehouse
declare -i nDistrict=$nWarehouse*10
# customer = 30000x
declare -i nCustomer=$nWarehouse*30000
# history = 30000x
declare -i nHistory=$nWarehouse*30000
# order = 30000x
# cluster nOrder=56250
declare -i nOrder=$nWarehouse*10
# new order = 9000x # 900/3000*30000
# cluster nNewOrder=56250
declare -i nNewOrder=$nWarehouse*10
# order line = 300000x
# cluster nOrderLine=56250
declare -i nOrderLine=$nWarehouse*10
# stock = 100000x
declare -i nStock=$nWarehouse*100000
# item = 100000
nItem=100000
## partition unit:
# cluster --
# order / order_line / new_order / history: by w_id 5625
# others: by w_id 90000
# small --
# history: by w_id nWarehouse / 8

declare -i nCore=96
declare -i nSmallCore=$nCore/3

echo > $OUTPUT_SQL

echo "create table bmsql_config (
  cfg_name    varchar(30) primary key,
  cfg_value   varchar(50)
);
" >> $OUTPUT_SQL

if [ $Mode -ne 1 ] ; then
echo "create cluster bmsql_warehouse_cluster (
  w_id integer
)
single table
hashkeys ${nWarehouse}
hash is ((w_id - 1))
size 3496
initrans 2
storage (buffer_pool default) parallel (degree ${nSmallCore});
" >> $OUTPUT_SQL
fi

if [ $Mode -eq 0 ] ; then
echo "create cluster bmsql_district_cluster (
  d_id integer,
  d_w_id integer
)
single table
hashkeys ${nDistrict}
hash is ( (((d_w_id-1)*10)+d_id-1) )
size 3496
initrans 4
storage (buffer_pool default) parallel (degree ${nSmallCore});
" >> $OUTPUT_SQL
fi

if [ $Mode -ne 1 ] ; then
echo "create cluster bmsql_customer_cluster (
  c_id integer,
  c_d_id integer,
  c_w_id integer
)
single table
hashkeys ${nCustomer}
hash is ( (c_id * (${nWarehouse} * 10) + c_w_id * 10 + c_d_id) )
size 850
pctfree 0 initrans 3
storage (buffer_pool recycle) parallel (degree ${nCore});
" >> $OUTPUT_SQL
# on cluster
# hash is ( (c_w_id * 30000 + c_id * 10 + c_d_id - 30011) )
fi

if [ $Mode -eq 0 ] ; then
echo "create cluster bmsql_new_order_cluster (
  no_w_id integer,
  no_d_id integer,
  no_o_id integer SORT
)
hashkeys ${nNewOrder}
hash is ((no_w_id - 1) * 10 + no_d_id -1)
size 190 parallel (degree ${nSmallCore});
" >> $OUTPUT_SQL
fi

if [ $Mode -eq 0 ] ; then
echo "create cluster bmsql_order_cluster (
  o_w_id integer,
  o_d_id integer,
  o_id integer SORT,
  ol_number integer SORT
)
hashkeys ${nOrder}
hash is ((o_w_id - 1) * 10 + o_d_id -1)
size 1490 parallel (degree ${nSmallCore});
" >> $OUTPUT_SQL
fi

if [ $Mode -ne 1 ] ; then
echo "create cluster bmsql_item_cluster (
  i_id integer
)
hashkeys ${nItem}
hash is ((i_id - 1))
size 120
pctfree 0 initrans 3
storage (buffer_pool keep);
" >> $OUTPUT_SQL
fi

if [ $Mode -ne 1 ] ; then
echo "create cluster bmsql_stock_cluster (
  s_w_id integer,
  s_i_id integer
)
single table
hashkeys ${nStock}
hash is ( (s_i_id-1) * ${nWarehouse} + s_w_id-1 )
size 270
pctfree 0 initrans 2 maxtrans 2
storage (buffer_pool keep) parallel (degree ${nCore});
" >> $OUTPUT_SQL
# on cluster
# hash is ((abs(s_i_id-1) * ${nWarehouse} + mod((s_w_id-1), ${nWarehouse}) + trunc((s_w_id-1) / ${nWarehouse}) * ${nWarehouse} * 100000))
fi

echo "create table bmsql_warehouse (
  w_id        integer   not null,
  w_ytd       decimal(12,2),
  w_tax       decimal(4,4),
  w_name      varchar(10),
  w_street_1  varchar(20),
  w_street_2  varchar(20),
  w_city      varchar(20),
  w_state     char(2),
  w_zip       char(9)
)" >> $OUTPUT_SQL

if [ $Mode -eq 1 ] ; then
echo "initrans 2
storage (buffer_pool default) parallel (degree ${nSmallCore});
" >> $OUTPUT_SQL
else
echo "cluster bmsql_warehouse_cluster(
  w_id
);
" >> $OUTPUT_SQL
fi

echo "create table bmsql_district (
  d_id         integer       not null,
  d_w_id       integer       not null,
  d_ytd        decimal(12,2),
  d_tax        decimal(4,4),
  d_next_o_id  integer,
  d_name       varchar(10),
  d_street_1   varchar(20),
  d_street_2   varchar(20),
  d_city       varchar(20),
  d_state      char(2),
  d_zip        char(9)
)" >> $OUTPUT_SQL

if [ $Mode -eq 0 ] ; then
echo "cluster bmsql_district_cluster(
  d_id, d_w_id
);
" >> $OUTPUT_SQL
else
echo "initrans 4
storage (buffer_pool default) parallel (degree ${nSmallCore});
" >> $OUTPUT_SQL
fi

echo "create table bmsql_customer (
  c_id           integer        not null,
  c_d_id         integer        not null,
  c_w_id         integer        not null,
  c_discount     decimal(4,4),
  c_credit       char(2),
  c_last         varchar(16),
  c_first        varchar(16),
  c_credit_lim   decimal(12,2),
  c_balance      decimal(12,2),
  c_ytd_payment  decimal(12,2),
  c_payment_cnt  integer,
  c_delivery_cnt integer,
  c_street_1     varchar(20),
  c_street_2     varchar(20),
  c_city         varchar(20),
  c_state        char(2),
  c_zip          char(9),
  c_phone        char(16),
  c_since        timestamp,
  c_middle       char(2),
  c_data         varchar(500)
)" >> $OUTPUT_SQL

if [ $Mode -eq 1 ] ; then
echo "pctfree 0 initrans 3
storage (buffer_pool recycle) parallel (degree ${nCore});
" >> $OUTPUT_SQL
else
echo "cluster bmsql_customer_cluster (
  c_id, c_d_id, c_w_id
);
" >> $OUTPUT_SQL
fi

echo "create table bmsql_history (
  -- hist_id  integer,
  h_c_id   integer,
  h_c_d_id integer,
  h_c_w_id integer,
  h_d_id   integer,
  h_w_id   integer,
  h_date   timestamp,
  h_amount decimal(6,2),
  h_data   varchar(24)
)
pctfree 5 initrans 4
storage (buffer_pool recycle);
" >> $OUTPUT_SQL

echo "create table bmsql_new_order (
  no_w_id  integer   not null,
  no_d_id  integer   not null,
  no_o_id  integer   sort
)" >> $OUTPUT_SQL

if [ $Mode -eq 0 ] ; then
echo "cluster bmsql_new_order_cluster (
  no_w_id, no_d_id, no_o_id
);
" >> $OUTPUT_SQL
else
echo "parallel (degree ${nSmallCore});
" >> $OUTPUT_SQL
fi

echo "create table bmsql_oorder (
  o_w_id       integer      not null,
  o_d_id       integer      not null,
  o_id         integer      sort,
  o_c_id       integer,
  o_carrier_id integer,
  o_ol_cnt     integer,
  o_all_local  integer,
  o_entry_d    timestamp
)" >> $OUTPUT_SQL

if [ $Mode -eq 0 ] ; then
echo "cluster bmsql_order_cluster (
  o_w_id, o_d_id, o_id
);
" >> $OUTPUT_SQL
else
echo "parallel (degree ${nSmallCore});
" >> $OUTPUT_SQL
fi

echo "create table bmsql_order_line (
  ol_w_id         integer   not null,
  ol_d_id         integer   not null,
  ol_o_id         integer   sort,
  ol_number       integer   sort,
  ol_i_id         integer   not null,
  ol_delivery_d   timestamp,
  ol_amount       decimal(6,2),
  ol_supply_w_id  integer,
  ol_quantity     integer,
  ol_dist_info    char(24)
)" >> $OUTPUT_SQL

if [ $Mode -eq 0 ] ; then
echo "cluster bmsql_order_cluster (
  ol_w_id, ol_d_id, ol_o_id, ol_number
);
" >> $OUTPUT_SQL
else
echo "parallel (degree ${nSmallCore});
" >> $OUTPUT_SQL
fi

echo "create table bmsql_item (
  i_id     integer      not null,
  i_name   varchar(24),
  i_price  decimal(5,2),
  i_data   varchar(50),
  i_im_id  integer
)" >> $OUTPUT_SQL

if [ $Mode -eq 1 ] ; then
echo "pctfree 0 initrans 3
storage (buffer_pool keep);
" >> $OUTPUT_SQL
else
echo "cluster bmsql_item_cluster(
  i_id
);
" >> $OUTPUT_SQL
fi

echo "create table bmsql_stock (
  s_w_id       integer       not null,
  s_i_id       integer       not null,
  s_quantity   integer,
  s_ytd        integer,
  s_order_cnt  integer,
  s_remote_cnt integer,
  s_data       varchar(50),
  s_dist_01    char(24),
  s_dist_02    char(24),
  s_dist_03    char(24),
  s_dist_04    char(24),
  s_dist_05    char(24),
  s_dist_06    char(24),
  s_dist_07    char(24),
  s_dist_08    char(24),
  s_dist_09    char(24),
  s_dist_10    char(24)
)" >> $OUTPUT_SQL

if [ $Mode -eq 1 ] ; then
echo "pctfree 0 initrans 2 maxtrans 2
storage (buffer_pool keep) parallel (degree ${nCore});
" >> $OUTPUT_SQL
else
echo "cluster bmsql_stock_cluster(
  s_w_id, s_i_id
);
" >> $OUTPUT_SQL
fi

echo "alter system flush shared_pool;" >> $OUTPUT_SQL;