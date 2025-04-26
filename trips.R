library(data.table)
trips.dt <- fread("trips.csv")
## each day you were physically present in Canada as an authorized
## temporary resident or protected person before you became a
## permanent resident counts as half a day
orig.enter <- as.IDate("2024-05-30")
## each day you were physically present in Canada after you became a
## permanent resident counts as one day;
became.pr <- as.IDate("2025-01-08")
app.date <- as.IDate(Sys.time())
app.date <- as.IDate("2028-04-01")

day.dt <- data.table(
  date=seq(orig.enter, app.date, by="day"),
  country="Canada"
)[
  trips.dt,
  country := countries,
  on=.(date>departed, date<returned)
][
, weight := fcase(
  country != "Canada", 0,
  date<became.pr, 0.5,
  default=1)
][]
fwrite(day.dt,"days.csv")

## You must be physically present in Canada for at least 1,095 days
## during the 5 years right before the date you applied
min.days <- 1095
day.dt[, cat(
  sum(weight),
  "days in Canada between",
  format(date[1]),
  "and",
  format(date[.N]),
  "whereas min number required for citizenship is",
  min.days,
  "\n")]
