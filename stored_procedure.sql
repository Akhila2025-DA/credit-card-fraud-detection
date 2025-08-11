SELECT * FROM credit_card_fraud_detection.tratransaction;
use  credit_card_fraud_detection;
CREATE TABLE IF NOT EXISTS suspicious_fraud_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trans_num VARCHAR(100),
    cc_num BIGINT,
    trans_date DATETIME,
    amt DECIMAL(10,2),
    merchant VARCHAR(255),
    category VARCHAR(100),
    is_fraud BOOLEAN,
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
delimiter $$
CREATE PROCEDURE DetectSuspiciousFrauds()
BEGIN
    -- Rule 1: High amount
    INSERT INTO suspicious_fraud_log (trans_num, cc_num, trans_date, amt, merchant, category, is_fraud, reason)
    SELECT trans_num, cc_num, STR_TO_DATE(trans_date_trans_time, '%d-%m-%Y %H:%i'), amt, merchant, category, is_fraud, 'High amount > 10000'
    FROM tratransaction
    WHERE amt > 10000
      AND trans_num NOT IN (SELECT trans_num FROM suspicious_fraud_log);

    -- Rule 2: Already marked as fraud
    INSERT INTO suspicious_fraud_log (trans_num, cc_num, trans_date, amt, merchant, category, is_fraud, reason)
    SELECT trans_num, cc_num, STR_TO_DATE(trans_date_trans_time, '%d-%m-%Y %H:%i'), amt, merchant, category, is_fraud, 'Labeled as fraud'
    FROM tratransaction
    WHERE is_fraud = 1
      AND trans_num NOT IN (SELECT trans_num FROM suspicious_fraud_log);

    -- Rule 3: Transaction during odd hours (12AM–5AM)
    INSERT INTO suspicious_fraud_log (trans_num, cc_num, trans_date, amt, merchant, category, is_fraud, reason)
    SELECT trans_num, cc_num, STR_TO_DATE(trans_date_trans_time, '%d-%m-%Y %H:%i'), amt, merchant, category, is_fraud, 'Odd transaction hour'
    FROM tratransaction
    WHERE HOUR(STR_TO_DATE(trans_date_trans_time, '%d-%m-%Y %H:%i')) BETWEEN 0 AND 5
      AND trans_num NOT IN (SELECT trans_num FROM suspicious_fraud_log);

    -- Rule 4: High-risk merchant category
    INSERT INTO suspicious_fraud_log (trans_num, cc_num, trans_date, amt, merchant, category, is_fraud, reason)
    SELECT trans_num, cc_num, STR_TO_DATE(trans_date_trans_time, '%d-%m-%Y %H:%i'), amt, merchant, category, is_fraud, 'High-risk category'
    FROM tratransaction
    WHERE category IN ('shopping_net', 'misc_net')
      AND trans_num NOT IN (SELECT trans_num FROM suspicious_fraud_log);
END$$
DELIMITER ;
CALL DetectSuspiciousFrauds();


