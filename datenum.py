from datetime import datetime, timedelta
def datetime_to_datenum(dt_str):
   dt=datetime.strptime(dt_str, '%Y-%m-%d %H:%M:%S')
   ord = dt.toordinal()
   mdn = dt + timedelta(days = 366)
   frac = (dt-datetime(dt.year,dt.month,dt.day,0,0,0)).seconds / (24.0 * 60.0 * 60.0)
   return mdn.toordinal() + frac

def datenum_to_datetime(datenum):
    import datetime
    days = datenum % 1
    hours = days % 1 * 24
    minutes = hours % 1 * 60
    seconds = minutes % 1 * 60
    return datetime.datetime.fromordinal(int(datenum)) \
           + datetime.timedelta(days=int(days)) \
           + datetime.timedelta(hours=int(hours)) \
           + datetime.timedelta(minutes=int(minutes)) \
           + datetime.timedelta(seconds=round(seconds)) \
           - datetime.timedelta(days=366)


def muestra():
   f1='2019-12-20 00:00:00'
   print(f1)
   s1=datetime_to_datenum(f1)
   print(type(s1))
   print(s1)

   f2='2019-12-27 23:59:59'
   print(f2)
   s2=datetime_to_datenum(f2)
   print(type(s2))
   print(s2)

if __name__ == "__main__":
   muestra()