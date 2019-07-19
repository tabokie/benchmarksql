-- analyze
/
BEGIN dbms_stats.GATHER_TABLE_STATS(
    ownname => 'BMSQL',
    tabname => 'bmsql_stock',
    estimate_percent => 1,
    block_sample => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1',
    degree => 96*2,
    granularity => 'DEFAULT',
    cascade => TRUE
);
END;
/
/
BEGIN dbms_stats.GATHER_TABLE_STATS(
    ownname => 'BMSQL',
    tabname => 'bmsql_new_order',
    estimate_percent => 1,
    block_sample => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1',
    degree => 96*2,
    granularity => 'DEFAULT',
    cascade => TRUE
);
END;
/
/
BEGIN dbms_stats.GATHER_TABLE_STATS(
    ownname => 'BMSQL',
    tabname => 'bmsql_order_line',
    estimate_percent => 1,
    block_sample => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1',
    degree => 96*2,
    granularity => 'DEFAULT',
    cascade => TRUE
);
END;
/
/
BEGIN dbms_stats.GATHER_TABLE_STATS(
    ownname => 'BMSQL',
    tabname => 'bmsql_oorder',
    estimate_percent => 1,
    block_sample => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1',
    degree => 96*2,
    granularity => 'DEFAULT',
    cascade => TRUE
);
END;
/
/
BEGIN dbms_stats.GATHER_TABLE_STATS(
    ownname => 'BMSQL',
    tabname => 'bmsql_history',
    estimate_percent => 1,
    block_sample => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1',
    degree => 96*2,
    granularity => 'DEFAULT',
    cascade => TRUE
);
END;
/
/
BEGIN dbms_stats.GATHER_TABLE_STATS(
    ownname => 'BMSQL',
    tabname => 'bmsql_customer',
    estimate_percent => 1,
    block_sample => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1',
    degree => 96*2,
    granularity => 'DEFAULT',
    cascade => TRUE
);
END;
/
/
BEGIN dbms_stats.GATHER_TABLE_STATS(
    ownname => 'BMSQL',
    tabname => 'bmsql_item',
    estimate_percent => 10,
    block_sample => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1',
    degree => 1,
    granularity => 'DEFAULT',
    cascade => TRUE
);
END;
/
/
BEGIN dbms_stats.GATHER_TABLE_STATS(
    ownname => 'BMSQL',
    tabname => 'bmsql_district',
    estimate_percent => 1,
    block_sample => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1',
    degree => 10,
    granularity => 'DEFAULT',
    cascade => TRUE
);
END;
/
/
BEGIN dbms_stats.GATHER_TABLE_STATS(
    ownname => 'BMSQL',
    tabname => 'bmsql_warehouse',
    estimate_percent => 10,
    block_sample => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1',
    degree => 10,
    granularity => 'DEFAULT',
    cascade => TRUE
);
END;
/