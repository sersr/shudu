const int threeDays = 1000 * 60 * 60 * 24 * 3;
const int thirtySeconds = 1000 * 30;
const errorImg = 'guizhenwuji.jpg';

final trimReg = RegExp('\u0009|\u000B|\u000C|\u000D|\u0020|'
    '\u00A0|\u1680|\uFEFF|\u205F|\u202F|\u2028|\u2000|\u2001|\u2002|'
    '\u2003|\u2004|\u2005|\u2006|\u2007|\u2008|\u2009|\u200A|(&nbsp;)+');
