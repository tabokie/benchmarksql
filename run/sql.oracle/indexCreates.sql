-- configured for 96c setup
create unique index bmsql_warehouse_pkey
  on bmsql_warehouse (w_id)
--   local(
-- partition iware_0
-- , partition iware_1
-- , partition iware_2
-- , partition iware_3
-- , partition iware_4
-- , partition iware_5
-- , partition iware_6
-- , partition iware_7
-- , partition iware_8
-- , partition iware_9
-- , partition iware_10
-- , partition iware_11
-- , partition iware_12
-- , partition iware_13
-- , partition iware_14
-- , partition iware_15
-- , partition iware_16
-- , partition iware_17
-- , partition iware_18
-- , partition iware_19
-- , partition iware_20
-- , partition iware_21
-- , partition iware_22
-- , partition iware_23
-- , partition iware_24
-- , partition iware_25
-- , partition iware_26
-- )
  parallel 32
  pctfree 1 initrans 3
  compute statistics;

create unique index bmsql_district_pkey
  on bmsql_district (d_w_id, d_id)
--   local (
-- partition idist_0
-- , partition idist_1
-- , partition idist_2
-- , partition idist_3
-- , partition idist_4
-- , partition idist_5
-- , partition idist_6
-- , partition idist_7
-- , partition idist_8
-- , partition idist_9
-- , partition idist_10
-- , partition idist_11
-- , partition idist_12
-- , partition idist_13
-- , partition idist_14
-- , partition idist_15
-- , partition idist_16
-- , partition idist_17
-- , partition idist_18
-- , partition idist_19
-- , partition idist_20
-- , partition idist_21
-- , partition idist_22
-- , partition idist_23
-- , partition idist_24
-- , partition idist_25
-- , partition idist_26
-- )
  pctfree 5 initrans 3
  parallel 1
  compute statistics;

create unique index bmsql_customer_pkey
  on bmsql_customer (c_w_id, c_d_id, c_id) -- reverse
--   local (
-- partition icust1_0
-- , partition icust1_1
-- , partition icust1_2
-- , partition icust1_3
-- , partition icust1_4
-- , partition icust1_5
-- , partition icust1_6
-- , partition icust1_7
-- , partition icust1_8
-- , partition icust1_9
-- , partition icust1_10
-- , partition icust1_11
-- , partition icust1_12
-- , partition icust1_13
-- , partition icust1_14
-- , partition icust1_15
-- , partition icust1_16
-- , partition icust1_17
-- , partition icust1_18
-- , partition icust1_19
-- , partition icust1_20
-- , partition icust1_21
-- , partition icust1_22
-- , partition icust1_23
-- , partition icust1_24
-- , partition icust1_25
-- , partition icust1_26
-- )
  parallel 32
  pctfree 1 initrans 3
  compute statistics;

create unique index bmsql_customer_idx
  on  bmsql_customer (c_w_id, c_last, c_d_id, c_first, c_id)
--   local (
-- partition icust2_0
-- , partition icust2_1
-- , partition icust2_2
-- , partition icust2_3
-- , partition icust2_4
-- , partition icust2_5
-- , partition icust2_6
-- , partition icust2_7
-- , partition icust2_8
-- , partition icust2_9
-- , partition icust2_10
-- , partition icust2_11
-- , partition icust2_12
-- , partition icust2_13
-- , partition icust2_14
-- , partition icust2_15
-- , partition icust2_16
-- , partition icust2_17
-- , partition icust2_18
-- , partition icust2_19
-- , partition icust2_20
-- , partition icust2_21
-- , partition icust2_22
-- , partition icust2_23
-- , partition icust2_24
-- , partition icust2_25
-- , partition icust2_26
-- )
  parallel 32
  pctfree 1 initrans 3
  compute statistics;

-- create unique index bmsql_oorder_pkey
--   on bmsql_oorder (o_w_id, o_d_id, o_id)
--   parallel 32
--   compute statistics;

create unique index bmsql_oorder_pkey
  on bmsql_oorder (o_w_id, o_d_id, o_c_id, o_id) -- reverse
--   local (
-- partition ioorder2_0
-- , partition ioorder2_1
-- , partition ioorder2_2
-- , partition ioorder2_3
-- , partition ioorder2_4
-- , partition ioorder2_5
-- , partition ioorder2_6
-- , partition ioorder2_7
-- , partition ioorder2_8
-- , partition ioorder2_9
-- , partition ioorder2_10
-- , partition ioorder2_11
-- , partition ioorder2_12
-- , partition ioorder2_13
-- , partition ioorder2_14
-- , partition ioorder2_15
-- , partition ioorder2_16
-- , partition ioorder2_17
-- , partition ioorder2_18
-- , partition ioorder2_19
-- , partition ioorder2_20
-- , partition ioorder2_21
-- , partition ioorder2_22
-- , partition ioorder2_23
-- , partition ioorder2_24
-- , partition ioorder2_25
-- , partition ioorder2_26
-- , partition ioorder2_27
-- , partition ioorder2_28
-- , partition ioorder2_29
-- , partition ioorder2_30
-- , partition ioorder2_31
-- , partition ioorder2_32
-- , partition ioorder2_33
-- , partition ioorder2_34
-- , partition ioorder2_35
-- , partition ioorder2_36
-- , partition ioorder2_37
-- , partition ioorder2_38
-- , partition ioorder2_39
-- , partition ioorder2_40
-- , partition ioorder2_41
-- , partition ioorder2_42
-- , partition ioorder2_43
-- , partition ioorder2_44
-- , partition ioorder2_45
-- , partition ioorder2_46
-- , partition ioorder2_47
-- , partition ioorder2_48
-- , partition ioorder2_49
-- , partition ioorder2_50
-- , partition ioorder2_51
-- , partition ioorder2_52
-- , partition ioorder2_53
-- , partition ioorder2_54
-- , partition ioorder2_55
-- , partition ioorder2_56
-- , partition ioorder2_57
-- , partition ioorder2_58
-- , partition ioorder2_59
-- , partition ioorder2_60
-- , partition ioorder2_61
-- , partition ioorder2_62
-- , partition ioorder2_63
-- , partition ioorder2_64
-- , partition ioorder2_65
-- , partition ioorder2_66
-- , partition ioorder2_67
-- , partition ioorder2_68
-- , partition ioorder2_69
-- , partition ioorder2_70
-- , partition ioorder2_71
-- , partition ioorder2_72
-- , partition ioorder2_73
-- , partition ioorder2_74
-- , partition ioorder2_75
-- , partition ioorder2_76
-- , partition ioorder2_77
-- , partition ioorder2_78
-- , partition ioorder2_79
-- , partition ioorder2_80
-- , partition ioorder2_81
-- , partition ioorder2_82
-- , partition ioorder2_83
-- , partition ioorder2_84
-- , partition ioorder2_85
-- , partition ioorder2_86
-- , partition ioorder2_87
-- , partition ioorder2_88
-- , partition ioorder2_89
-- , partition ioorder2_90
-- , partition ioorder2_91
-- , partition ioorder2_92
-- , partition ioorder2_93
-- , partition ioorder2_94
-- , partition ioorder2_95
-- , partition ioorder2_96
-- , partition ioorder2_97
-- , partition ioorder2_98
-- , partition ioorder2_99
-- , partition ioorder2_100
-- , partition ioorder2_101
-- , partition ioorder2_102
-- , partition ioorder2_103
-- , partition ioorder2_104
-- , partition ioorder2_105
-- , partition ioorder2_106
-- , partition ioorder2_107
-- , partition ioorder2_108
-- , partition ioorder2_109
-- , partition ioorder2_110
-- , partition ioorder2_111
-- , partition ioorder2_112
-- , partition ioorder2_113
-- , partition ioorder2_114
-- , partition ioorder2_115
-- , partition ioorder2_116
-- , partition ioorder2_117
-- , partition ioorder2_118
-- , partition ioorder2_119
-- , partition ioorder2_120
-- , partition ioorder2_121
-- , partition ioorder2_122
-- , partition ioorder2_123
-- , partition ioorder2_124
-- , partition ioorder2_125
-- , partition ioorder2_126
-- , partition ioorder2_127
-- , partition ioorder2_128
-- , partition ioorder2_129
-- , partition ioorder2_130
-- , partition ioorder2_131
-- , partition ioorder2_132
-- , partition ioorder2_133
-- , partition ioorder2_134
-- , partition ioorder2_135
-- , partition ioorder2_136
-- , partition ioorder2_137
-- , partition ioorder2_138
-- , partition ioorder2_139
-- , partition ioorder2_140
-- , partition ioorder2_141
-- , partition ioorder2_142
-- , partition ioorder2_143
-- , partition ioorder2_144
-- , partition ioorder2_145
-- , partition ioorder2_146
-- , partition ioorder2_147
-- , partition ioorder2_148
-- , partition ioorder2_149
-- , partition ioorder2_150
-- , partition ioorder2_151
-- , partition ioorder2_152
-- , partition ioorder2_153
-- , partition ioorder2_154
-- , partition ioorder2_155
-- , partition ioorder2_156
-- , partition ioorder2_157
-- , partition ioorder2_158
-- , partition ioorder2_159
-- , partition ioorder2_160
-- , partition ioorder2_161
-- , partition ioorder2_162
-- , partition ioorder2_163
-- , partition ioorder2_164
-- , partition ioorder2_165
-- , partition ioorder2_166
-- , partition ioorder2_167
-- , partition ioorder2_168
-- , partition ioorder2_169
-- , partition ioorder2_170
-- , partition ioorder2_171
-- , partition ioorder2_172
-- , partition ioorder2_173
-- , partition ioorder2_174
-- , partition ioorder2_175
-- , partition ioorder2_176
-- , partition ioorder2_177
-- , partition ioorder2_178
-- , partition ioorder2_179
-- , partition ioorder2_180
-- , partition ioorder2_181
-- , partition ioorder2_182
-- , partition ioorder2_183
-- , partition ioorder2_184
-- , partition ioorder2_185
-- , partition ioorder2_186
-- , partition ioorder2_187
-- , partition ioorder2_188
-- , partition ioorder2_189
-- , partition ioorder2_190
-- , partition ioorder2_191
-- , partition ioorder2_192
-- , partition ioorder2_193
-- , partition ioorder2_194
-- , partition ioorder2_195
-- , partition ioorder2_196
-- , partition ioorder2_197
-- , partition ioorder2_198
-- , partition ioorder2_199
-- , partition ioorder2_200
-- , partition ioorder2_201
-- , partition ioorder2_202
-- , partition ioorder2_203
-- , partition ioorder2_204
-- , partition ioorder2_205
-- , partition ioorder2_206
-- , partition ioorder2_207
-- , partition ioorder2_208
-- , partition ioorder2_209
-- , partition ioorder2_210
-- , partition ioorder2_211
-- , partition ioorder2_212
-- , partition ioorder2_213
-- , partition ioorder2_214
-- , partition ioorder2_215
-- , partition ioorder2_216
-- , partition ioorder2_217
-- , partition ioorder2_218
-- , partition ioorder2_219
-- , partition ioorder2_220
-- , partition ioorder2_221
-- , partition ioorder2_222
-- , partition ioorder2_223
-- , partition ioorder2_224
-- , partition ioorder2_225
-- , partition ioorder2_226
-- , partition ioorder2_227
-- , partition ioorder2_228
-- , partition ioorder2_229
-- , partition ioorder2_230
-- , partition ioorder2_231
-- , partition ioorder2_232
-- , partition ioorder2_233
-- , partition ioorder2_234
-- , partition ioorder2_235
-- , partition ioorder2_236
-- , partition ioorder2_237
-- , partition ioorder2_238
-- , partition ioorder2_239
-- , partition ioorder2_240
-- , partition ioorder2_241
-- , partition ioorder2_242
-- , partition ioorder2_243
-- , partition ioorder2_244
-- , partition ioorder2_245
-- , partition ioorder2_246
-- , partition ioorder2_247
-- , partition ioorder2_248
-- , partition ioorder2_249
-- , partition ioorder2_250
-- , partition ioorder2_251
-- , partition ioorder2_252
-- , partition ioorder2_253
-- , partition ioorder2_254
-- , partition ioorder2_255
-- , partition ioorder2_256
-- , partition ioorder2_257
-- , partition ioorder2_258
-- , partition ioorder2_259
-- , partition ioorder2_260
-- , partition ioorder2_261
-- , partition ioorder2_262
-- , partition ioorder2_263
-- , partition ioorder2_264
-- , partition ioorder2_265
-- , partition ioorder2_266
-- , partition ioorder2_267
-- , partition ioorder2_268
-- , partition ioorder2_269
-- , partition ioorder2_270
-- , partition ioorder2_271
-- , partition ioorder2_272
-- , partition ioorder2_273
-- , partition ioorder2_274
-- , partition ioorder2_275
-- , partition ioorder2_276
-- , partition ioorder2_277
-- , partition ioorder2_278
-- , partition ioorder2_279
-- , partition ioorder2_280
-- , partition ioorder2_281
-- , partition ioorder2_282
-- , partition ioorder2_283
-- , partition ioorder2_284
-- , partition ioorder2_285
-- , partition ioorder2_286
-- , partition ioorder2_287
-- , partition ioorder2_288
-- , partition ioorder2_289
-- , partition ioorder2_290
-- , partition ioorder2_291
-- , partition ioorder2_292
-- , partition ioorder2_293
-- , partition ioorder2_294
-- , partition ioorder2_295
-- , partition ioorder2_296
-- , partition ioorder2_297
-- , partition ioorder2_298
-- , partition ioorder2_299
-- , partition ioorder2_300
-- , partition ioorder2_301
-- , partition ioorder2_302
-- , partition ioorder2_303
-- , partition ioorder2_304
-- , partition ioorder2_305
-- , partition ioorder2_306
-- , partition ioorder2_307
-- , partition ioorder2_308
-- , partition ioorder2_309
-- , partition ioorder2_310
-- , partition ioorder2_311
-- , partition ioorder2_312
-- , partition ioorder2_313
-- , partition ioorder2_314
-- , partition ioorder2_315
-- , partition ioorder2_316
-- , partition ioorder2_317
-- , partition ioorder2_318
-- , partition ioorder2_319
-- , partition ioorder2_320
-- , partition ioorder2_321
-- , partition ioorder2_322
-- , partition ioorder2_323
-- , partition ioorder2_324
-- , partition ioorder2_325
-- , partition ioorder2_326
-- , partition ioorder2_327
-- , partition ioorder2_328
-- , partition ioorder2_329
-- , partition ioorder2_330
-- , partition ioorder2_331
-- , partition ioorder2_332
-- , partition ioorder2_333
-- , partition ioorder2_334
-- , partition ioorder2_335
-- , partition ioorder2_336
-- , partition ioorder2_337
-- , partition ioorder2_338
-- , partition ioorder2_339
-- , partition ioorder2_340
-- , partition ioorder2_341
-- , partition ioorder2_342
-- , partition ioorder2_343
-- , partition ioorder2_344
-- , partition ioorder2_345
-- , partition ioorder2_346
-- , partition ioorder2_347
-- , partition ioorder2_348
-- , partition ioorder2_349
-- , partition ioorder2_350
-- , partition ioorder2_351
-- , partition ioorder2_352
-- , partition ioorder2_353
-- , partition ioorder2_354
-- , partition ioorder2_355
-- , partition ioorder2_356
-- , partition ioorder2_357
-- , partition ioorder2_358
-- , partition ioorder2_359
-- , partition ioorder2_360
-- , partition ioorder2_361
-- , partition ioorder2_362
-- , partition ioorder2_363
-- , partition ioorder2_364
-- , partition ioorder2_365
-- , partition ioorder2_366
-- , partition ioorder2_367
-- , partition ioorder2_368
-- , partition ioorder2_369
-- , partition ioorder2_370
-- , partition ioorder2_371
-- , partition ioorder2_372
-- , partition ioorder2_373
-- , partition ioorder2_374
-- , partition ioorder2_375
-- , partition ioorder2_376
-- , partition ioorder2_377
-- , partition ioorder2_378
-- , partition ioorder2_379
-- , partition ioorder2_380
-- , partition ioorder2_381
-- , partition ioorder2_382
-- , partition ioorder2_383
-- , partition ioorder2_384
-- , partition ioorder2_385
-- , partition ioorder2_386
-- , partition ioorder2_387
-- , partition ioorder2_388
-- , partition ioorder2_389
-- , partition ioorder2_390
-- , partition ioorder2_391
-- , partition ioorder2_392
-- , partition ioorder2_393
-- , partition ioorder2_394
-- , partition ioorder2_395
-- , partition ioorder2_396
-- , partition ioorder2_397
-- , partition ioorder2_398
-- , partition ioorder2_399
-- , partition ioorder2_400
-- , partition ioorder2_401
-- , partition ioorder2_402
-- , partition ioorder2_403
-- , partition ioorder2_404
-- , partition ioorder2_405
-- , partition ioorder2_406
-- , partition ioorder2_407
-- , partition ioorder2_408
-- , partition ioorder2_409
-- , partition ioorder2_410
-- , partition ioorder2_411
-- , partition ioorder2_412
-- , partition ioorder2_413
-- , partition ioorder2_414
-- , partition ioorder2_415
-- , partition ioorder2_416
-- , partition ioorder2_417
-- , partition ioorder2_418
-- , partition ioorder2_419
-- , partition ioorder2_420
-- , partition ioorder2_421
-- , partition ioorder2_422
-- , partition ioorder2_423
-- , partition ioorder2_424
-- , partition ioorder2_425
-- , partition ioorder2_426
-- , partition ioorder2_427
-- , partition ioorder2_428
-- , partition ioorder2_429
-- , partition ioorder2_430
-- , partition ioorder2_431
-- )
  parallel 32
  pctfree 25 initrans 4
  compute statistics;

create unique index bmsql_new_order_pkey
  on bmsql_new_order (no_w_id, no_d_id, no_o_id)
  compute statistics;

create unique index bmsql_order_line_pkey
  on bmsql_order_line (ol_w_id, ol_d_id, ol_o_id, ol_number)
  compute statistics;

create unique index bmsql_stock_pkey
  on bmsql_stock (s_i_id, s_w_id) -- reverse
--   local(
-- partition istock_0
-- , partition istock_1
-- , partition istock_2
-- , partition istock_3
-- , partition istock_4
-- , partition istock_5
-- , partition istock_6
-- , partition istock_7
-- , partition istock_8
-- , partition istock_9
-- , partition istock_10
-- , partition istock_11
-- , partition istock_12
-- , partition istock_13
-- , partition istock_14
-- , partition istock_15
-- , partition istock_16
-- , partition istock_17
-- , partition istock_18
-- , partition istock_19
-- , partition istock_20
-- , partition istock_21
-- , partition istock_22
-- , partition istock_23
-- , partition istock_24
-- , partition istock_25
-- , partition istock_26
-- )
  parallel 32
  pctfree 1 initrans 3
  compute statistics;

create unique index bmsql_item_pkey
  on bmsql_item (i_id)
  pctfree 5 initrans 4
  compute statistics;

-- execute in sqlplus
-- exec dbms_stats.gather_schema_stats( -
--   ownname          => 'BMSQL', -
--   options          => 'GATHER AUTO', -
--   estimate_percent => dbms_stats.auto_sample_size, -
--   method_opt       => 'for all columns size repeat', -
--   degree           => 34 -
-- );