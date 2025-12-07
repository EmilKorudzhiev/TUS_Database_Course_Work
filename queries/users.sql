CREATE USER 'admin_user'@'%' IDENTIFIED BY 'admin_password';
CREATE USER 'analyst_user'@'%' IDENTIFIED BY 'analyst_password';
CREATE USER 'app_user'@'%' IDENTIFIED BY 'app_password';

GRANT ALL PRIVILEGES ON *.* TO 'admin_user'@'%';

GRANT SELECT ON *.* TO 'analyst_user'@'%';

GRANT SELECT, UPDATE ON *.* TO 'app_user'@'%';

FLUSH PRIVILEGES;