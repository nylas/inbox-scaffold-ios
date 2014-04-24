CREATE TABLE `INContact` (
`id` integer primary key autoincrement,
`account_id` int(11) NOT NULL,
`uid` varchar(64) NOT NULL,
`provider_name` varchar(64) DEFAULT NULL,
`source` text DEFAULT NULL,
`email_address` varchar(254) DEFAULT NULL,
`name` text,
`raw_data` text,
`score` int(11) DEFAULT NULL,
`updated_at` datetime DEFAULT NULL,
`created_at` datetime DEFAULT NULL
)

CREATE UNIQUE INDEX `uid` ON INContact(`uid`,`source`,`account_id`,`provider_name`)

PRAGMA user_version = 1