
SELECT * FROM iems_station_station_info_t;

SELECT t.* FROM iems_kpi_amendment_task_t t WHERE task_name LIKE '%重算任务_%';

SET @taskId = -146005799820946;
SELECT FROM_UNIXTIME(create_time/1000), FROM_UNIXTIME(start_time/1000), FROM_UNIXTIME(end_time/1000), t.* FROM iems_kpi_amendment_task_t t WHERE task_id = @taskId;
SELECT FROM_UNIXTIME(amendment_time/1000), FROM_UNIXTIME(start_time/1000), FROM_UNIXTIME(end_time/1000), t.* FROM iems_kpi_amendment_station_t t WHERE general_task_id = @taskId ORDER BY amendment_time;

-- DELETE FROM iems_kpi_amendment_task_t WHERE task_id = @taskId;
-- DELETE FROM iems_kpi_amendment_station_t WHERE general_task_id = @taskId;

SELECT * FROM iems_kpi_amendment_task_t ORDER BY create_time desc;


DELETE FROM iems_kpi_amendment_station_t WHERE general_task_id IN (
	SELECT t.task_id FROM iems_kpi_amendment_task_t t WHERE task_name LIKE '%重算任务_%'
);
DELETE FROM iems_kpi_amendment_task_t WHERE task_name LIKE '%重算任务_%';





USE IEMS;

-- 手动创建KPI计算任务(建议在系统空闲时创建，计算周期不宜过长，建议根据日月年创建的修正应用的任务最大长度： 日31天，月12个月，年25年)
-- dateType 任务类型 1:日	2:月	3:年
-- dateLength 每个电站任务长度
-- sYear	开始年
-- sMonth	开始月
-- sDay	开始日
DROP PROCEDURE IF EXISTS clearKpiTask;
DELIMITER $$
CREATE PROCEDURE clearKpiTask(dateType TINYINT, dateLength TINYINT, sYear VARCHAR(4), sMonth VARCHAR(2), sDay VARCHAR(2)) 
BEGIN
	DECLARE sDate datetime;
	DECLARE eDate datetime;

	IF (dateLength IS NOT NULL AND dateLength > 0) THEN
		SET dateLength = dateLength - 1;
		-- 开始日期
		IF (dateType = 1) THEN
			SET sDate = DATE(CONCAT_WS('-',sYear,sMonth,sDay));
			SET eDate = DATE_ADD(sDate, INTERVAL dateLength DAY);
		ELSEIF (dateType = 2) THEN
			SET sDate = DATE(CONCAT_WS('-',sYear,sMonth,'01'));
			SET eDate = DATE_ADD(sDate, INTERVAL dateLength MONTH);
		ELSEIF (dateType = 3) THEN
			SET sDate = DATE(CONCAT_WS('-',sYear,'01','01'));
			SET eDate = DATE_ADD(sDate, INTERVAL dateLength YEAR);
		END IF;
	END IF;

	IF (sDate IS NOT NULL AND eDate IS NOT NULL) THEN
		-- 增加主任务
		SET @taskId = UUID_SHORT()%1000000000;
		INSERT INTO `iems_kpi_amendment_task_t` (`task_id`, `task_name`, `create_time`, `date_type`, `start_time`, `end_time`, `process`, `task_status`, `domain_id`, `create_user`)
			VALUES (@taskId, CONCAT('重算任务_',@taskId), UNIX_TIMESTAMP(NOW())*1000, dateType, UNIX_TIMESTAMP(sDate)*1000, UNIX_TIMESTAMP(eDate)*1000, NULL, 0, 1, 1);

		-- 增加电站任务
		WHILE sDate <= eDate DO
			INSERT INTO `iems_kpi_amendment_station_t` (`task_id`, `general_task_id`, `station_code`, `task_status`, `amendment_time`, `start_time`, `end_time`, `fail_cause`, `time_zone_id`)
			SELECT UUID_SHORT(), @taskId, station_code, 0, UNIX_TIMESTAMP(sDate)*1000, NULL, NULL, NULL, time_zone FROM `iems_station_station_info_t` s WHERE is_logic_delete = 0
					AND station_code IN ("C67EEBF9BE084E37AC89960516000AEB")
					;

-- 			SELECT @taskId, sDate, eDate;
			IF (dateType = 1) THEN
				SET sDate = DATE_ADD(sDate,INTERVAL 1 DAY);
			ELSEIF (dateType = 2) THEN
				SET sDate = DATE_ADD(sDate,INTERVAL 1 MONTH);
			ELSE
				SET sDate = DATE_ADD(sDate,INTERVAL 1 YEAR);
			END IF;

		END WHILE;
	END IF;
END; $$
DELIMITER ;

-- 从2020-09-01开始创建3天的计算任务
CALL clearKpiTask(1, 1, '2021', '3', '11');

DROP PROCEDURE IF EXISTS clearKpiTask;












-- 手动创建KPI计算任务(建议在系统空闲时创建，计算周期不宜过长，建议根据日月年创建的修正应用的任务最大长度： 日31天，月12个月，年25年)
-- dateType 任务类型 1:日	2:月	3:年
-- sDate	开始日期
-- eDate	日期日期
DROP PROCEDURE IF EXISTS clearKpiTask;
DELIMITER $$
CREATE PROCEDURE clearKpiTask(dateType TINYINT, sDateStr VARCHAR(10), eDateStr VARCHAR(10)) 
BEGIN
	DECLARE sDate datetime;
	DECLARE eDate datetime;

	IF (sDateStr IS NOT NULL AND eDateStr IS NOT NULL) THEN
		-- 开始日期
		IF (dateType = 1) THEN
			SET sDate = DATE(sDateStr);
			SET eDate = DATE(eDateStr);
		ELSEIF (dateType = 2) THEN
			SET sDate = DATE(CONCAT(SUBSTRING_INDEX(sDateStr,'-',2),'-01'));
			SET eDate = DATE(CONCAT(SUBSTRING_INDEX(eDateStr,'-',2),'-01'));
		ELSEIF (dateType = 3) THEN
			SET sDate = DATE(CONCAT(SUBSTRING_INDEX(sDateStr,'-',1),'-01-01'));
			SET eDate = DATE(CONCAT(SUBSTRING_INDEX(eDateStr,'-',1),'-01-01'));
		END IF;
	END IF;

	IF (sDate IS NOT NULL AND eDate IS NOT NULL AND sDate <= eDate) THEN
		-- 增加主任务
		SET @taskId = UUID_SHORT()%1000000000;
		INSERT INTO `iems_kpi_amendment_task_t` (`task_id`, `task_name`, `create_time`, `date_type`, `start_time`, `end_time`, `process`, `task_status`, `domain_id`, `create_user`)
			VALUES (@taskId, CONCAT('重算任务_',@taskId), UNIX_TIMESTAMP(NOW())*1000, dateType, UNIX_TIMESTAMP(sDate)*1000, UNIX_TIMESTAMP(eDate)*1000, NULL, 0, 1, 1);

		-- 增加电站任务
		WHILE sDate <= eDate DO
			INSERT INTO `iems_kpi_amendment_station_t` (`task_id`, `general_task_id`, `station_code`, `task_status`, `amendment_time`, `start_time`, `end_time`, `fail_cause`, `time_zone_id`)
			SELECT UUID_SHORT(), @taskId, station_code, 0, UNIX_TIMESTAMP(sDate)*1000, NULL, NULL, NULL, time_zone FROM `iems_station_station_info_t` s WHERE is_logic_delete = 0
					AND station_code IN ("A3A3266A237340DAAFFD75596DA031E2", "5B9564943EC01CBA88404A09831046DB")
					;

-- 			SELECT @taskId, sDate, eDate;
			IF (dateType = 1) THEN
				SET sDate = DATE_ADD(sDate,INTERVAL 1 DAY);
			ELSEIF (dateType = 2) THEN
				SET sDate = DATE_ADD(sDate,INTERVAL 1 MONTH);
			ELSE
				SET sDate = DATE_ADD(sDate,INTERVAL 1 YEAR);
			END IF;

		END WHILE;
	END IF;
END; $$
DELIMITER ;

-- 创建2020-10-15至2020-10-16天计算任务
CALL clearKpiTask(1, '2020-10-11', '2020-10-11');

DROP PROCEDURE IF EXISTS clearKpiTask;













-- 根据模板表创建分表
-- tplTab	模板表
-- tabPrefix	分表
-- dateType 任务类型 1:日分表	2:月分表 3:年分表 4:不分表
-- sDate	开始日期
-- eDate	日期日期
DROP PROCEDURE IF EXISTS addTab;
DELIMITER $$
CREATE PROCEDURE addTab(tplTab VARCHAR(128), tabPrefix VARCHAR(128), dateType TINYINT, sDateStr VARCHAR(10), eDateStr VARCHAR(10)) 
BEGIN
	DECLARE sDate datetime;
	DECLARE eDate datetime;
	DECLARE dateFmt VARCHAR(32);

	IF (tplTab IS NOT NULL AND tabPrefix IS NOT NULL AND sDateStr IS NOT NULL AND eDateStr IS NOT NULL) THEN
		-- 开始日期
		IF (dateType = 1) THEN
			SET sDate = DATE(sDateStr);
			SET eDate = DATE(eDateStr);
			SET dateFmt = '%Y%m%d';
		ELSEIF (dateType = 2) THEN
			SET sDate = DATE(CONCAT(SUBSTRING_INDEX(sDateStr,'-',2),'-01'));
			SET eDate = DATE(CONCAT(SUBSTRING_INDEX(eDateStr,'-',2),'-01'));
			SET dateFmt = '%Y%m';
		ELSEIF (dateType = 3) THEN
			SET sDate = DATE(CONCAT(SUBSTRING_INDEX(sDateStr,'-',1),'-01-01'));
			SET eDate = DATE(CONCAT(SUBSTRING_INDEX(eDateStr,'-',1),'-01-01'));
			SET dateFmt = '%Y';
		END IF;
	END IF;

	IF (sDate IS NOT NULL AND eDate IS NOT NULL AND sDate <= eDate) THEN
		WHILE sDate <= eDate DO
			SET @tname_sql = concat('CREATE TABLE IF NOT EXISTS ', tabPrefix, '_',DATE_FORMAT(sDate,dateFmt) ,' LIKE  ', tplTab);
-- 			SELECT @tname_sql, sDate, eDate;

			PREPARE addTab FROM @tname_sql;
			EXECUTE addTab ;
			DEALLOCATE PREPARE addTab;

			IF (dateType = 1) THEN
				SET sDate = DATE_ADD(sDate,INTERVAL 1 DAY);
			ELSEIF (dateType = 2) THEN
				SET sDate = DATE_ADD(sDate,INTERVAL 1 MONTH);
			ELSE
				SET sDate = DATE_ADD(sDate,INTERVAL 1 YEAR);
			END IF;

		END WHILE;
	ELSE
			SET @tname_sql = concat('CREATE TABLE IF NOT EXISTS ', tabPrefix, ' LIKE  ', tplTab);
-- 			SELECT @tname_sql;
			PREPARE addTab FROM @tname_sql;
			EXECUTE addTab ;
			DEALLOCATE PREPARE addTab;
	END IF;
END; $$
DELIMITER ;


CALL addTab('iems.iems_tpl_station_power_t', 'test.iems_station_power_t', 1, '2020-10-10', '2020-10-12');

DROP PROCEDURE IF EXISTS addTab;


