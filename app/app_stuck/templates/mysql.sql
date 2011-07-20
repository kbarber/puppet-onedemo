SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Table structure for table `ci_sessions`
--

CREATE TABLE IF NOT EXISTS `ci_sessions` (
  `session_id` varchar(40) character set utf8 NOT NULL default '0',
  `ip_address` varchar(16) character set utf8 NOT NULL default '0',
  `user_agent` varchar(50) character set utf8 NOT NULL,
  `last_activity` int(10) unsigned NOT NULL default '0',
  `session_data` text character set utf8 NOT NULL,
  `user_data` text character set utf8 NOT NULL,
  PRIMARY KEY  (`session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ;

--
-- Table structure for table `languages`
--

CREATE TABLE IF NOT EXISTS `languages` (
  `code` varchar(12) character set utf8 collate utf8_general_ci NOT NULL,
  `description` varchar(32) character set utf8 collate utf8_general_ci NOT NULL,
  `extension` varchar(12) character set utf8 collate utf8_general_ci NOT NULL,
  `isMain` tinyint(1) NOT NULL default '0',
  KEY `code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ;

--
-- Data for table `languages`
--

INSERT INTO `languages` (`code`, `description`, `extension`, `isMain`) VALUES
('c', 'C', 'c', 1),
('css', 'CSS', 'css', 1),
('cpp', 'C++', 'cpp', 1),
('html4strict', 'HTML (4 Strict)', 'html', 0),
('java', 'Java', 'java', 0),
('perl', 'Perl', 'pl', 1),
('php', 'PHP', 'php', 1),
('python', 'Python', 'py', 1),
('ruby', 'Ruby', 'rb', 1),
('text', 'Plain Text', 'txt', 1),
('asm', 'ASM (Nasm Syntax)', 'asm', 0),
('xhtml', 'XHTML', 'html', 1),
('actionscript', 'Actionscript', 'actionscript', 0),
('apache', 'Apache Log', 'log', 0),
('applescript', 'AppleScript', 'applescript', 0),
('bash', 'Bash', 'sh', 1),
('c_mac', 'C for Macs', 'c', 0),
('csharp', 'C#', 'cs', 0),
('delphi', 'Delphi', 'pas', 0),
('fortran', 'Fortran', 'for', 0),
('inno', 'Inno Setup', 'iss', 0),
('java5', 'Java 5', 'java', 0),
('javascript', 'Javascript', 'js', 0),
('latex', 'LaTeX', 'latex', 0),
('mirc', 'mIRC Script', 'mrc', 0),
('mysql', 'MySQL', 'sql', 1),
('nsis', 'NSIS', 'nsi', 0),
('objc', 'Objective C', 'm', 0),
('orcale8', 'Orcale 8 SQL', 'sql', 0),
('pascal', 'Pascal', 'pas', 0),
('robots', 'robots.txt', 'txt', 0),
('sql', 'SQL', 'sql', 1),
('winbatch', 'Windows Batch', 'bat', 0),
('xml', 'XML', 'xml', 0),
('verilog', 'Verilog', 'v', 0);

--
-- Table structure for table `pastes`
--

CREATE TABLE IF NOT EXISTS `pastes` (
  `id` int(10) NOT NULL auto_increment,
  `pid` varchar(8) character set utf8 collate utf8_general_ci NOT NULL,
  `title` varchar(128) character set utf8 collate utf8_general_ci NOT NULL,
  `name` varchar(64) character set utf8 collate utf8_general_ci NOT NULL,
  `lang` varchar(32) character set utf8 collate utf8_general_ci NOT NULL,
  `private` tinyint(1) NOT NULL,
  `paste` longtext character set utf8 collate utf8_general_ci NOT NULL,
  `raw` longtext character set utf8 collate utf8_general_ci NOT NULL,
  `filename` varchar(132) character set utf8 collate utf8_general_ci NOT NULL,
  `created` int(10) NOT NULL,
  `expire` int(10) NOT NULL default '0',
  `toexpire` tinyint(1) unsigned NOT NULL,
  `snipurl` varchar(64) character set utf8 collate utf8_general_ci NOT NULL default '0',
  `replyto` varchar(8) character set utf8 collate utf8_general_ci NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 ;
