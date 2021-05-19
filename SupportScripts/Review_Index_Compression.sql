SELECT 
SUBSTRING(sys.tables.name ,1,3),
SUBSTRING(sys.indexes.name,1,2),
       sys.tables.name AS TABLE_NAME,
       sys.partitions.data_compression_desc AS COMPRESSION_TYPE,
       sys.indexes.name as INDEX_NAME,
       CASE sys.indexes.is_primary_key
              WHEN 1 THEN 'Yes'
              WHEN 0 THEN 'No'
              ELSE 'Unknown'
       END AS PRIMARY_KEY_INDICATOR,
       sys.indexes.type_desc AS INDEX_CLUSTERING
FROM sys.tables
LEFT OUTER JOIN sys.partitions ON sys.tables.object_id = sys.partitions.object_id
LEFT OUTER JOIN sys.indexes ON sys.partitions.object_id = sys.indexes.object_id 
  AND sys.partitions.index_id = sys.indexes.index_id
WHERE OBJECTPROPERTY(sys.tables.OBJECT_ID,'ismsshipped') = 0
