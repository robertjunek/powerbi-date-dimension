// --------------------------------------------------------
// File: datedim.pq
// Author: Robert Junek, bisuperhero.cz
// Date: 2024-05-30
// License: MIT (https://opensource.org/licenses/MIT)
// Description: This file contains functions to prepare a
//              date dimension table in Power Query.
//              The table contains columns with various   
//              date attributes, such as day of week, year, 
//              day and week of year, month, quarter, etc.
//              The table also contains columns for Czech
//              and Slovak holidays.
// --------------------------------------------------------


let
    
    // Configuration
    Today = Date.From(DateTime.LocalNow()),
    FromYear = 2010,
    ToYear = 2020,
    firstDayofWeek = Day.Monday,
    FromDate = #date(FromYear, 1, 1),
    ToDate = #date(ToYear, 12, 31),
    Source = List.Dates(FromDate, Duration.Days(ToDate - FromDate) + 1, #duration(1, 0, 0, 0)),
    
    // Calculate Easter Monday
    CalculateEasterMonday = (year as number) as date =>
        let
            a = Number.Mod(year, 19),
            b = Number.IntegerDivide(year, 100),
            c = Number.Mod(year, 100),
            d = Number.IntegerDivide(b, 4),
            e = Number.Mod(b, 4),
            f = Number.IntegerDivide(b + 8, 25),
            g = Number.IntegerDivide(b - f + 1, 3),
            h = Number.Mod(19 * a + b - d - g + 15, 30),
            i = Number.IntegerDivide(c, 4),
            k = Number.Mod(c, 4),
            l = Number.Mod(32 + 2 * e + 2 * i - h - k, 7),
            m = Number.IntegerDivide(a + 11 * h + 22 * l, 451),
            month = Number.IntegerDivide(h + l - 7 * m + 114, 31),
            day = Number.Mod(h + l - 7 * m + 114, 31) + 1,
            easterSunday = #date(year, month, day)
        in
            Date.AddDays(easterSunday, 1),
    
    
    // Calculate Good Friday (two days before Easter Sunday)
    CalculateGoodFriday = (year as number) as date =>
        let
            easterSunday = Date.AddDays(CalculateEasterMonday(year), -1)
        in
            Date.AddDays(easterSunday, -2),
    
    
    // Function to determine if a date is a Czech holiday
    IsCzechHoliday = (date as date, year as number, month as number, day as number) as logical =>
        let
            isNewYear = month = 1 and day = 1,
            isLabourDay = month = 5 and day = 1,
            isVictoryDay = month = 5 and day = 8,
            isStCyrilMethodiusDay = year >= 1990 and month = 7 and day = 5,
            isJanHusDay = year >= 1990 and month = 7 and day = 6,
            isStatehoodDay = year >= 2000 and month = 9 and day = 28,
            isIndependenceDay = month = 10 and day = 28,
            isFreedomDemocracyDay = year >= 2000 and month = 11 and day = 17,
            isChristmasEve = month = 12 and day = 24,
            isChristmasDay = month = 12 and day = 25,
            isStStephensDay = month = 12 and day = 26,
            isGoodFriday = date = CalculateGoodFriday(year) and year >= 2016,
            isEasterMonday = date = CalculateEasterMonday(year)
        in
            isNewYear
            or isLabourDay
            or isVictoryDay
            or isStCyrilMethodiusDay
            or isJanHusDay
            or isStatehoodDay
            or isIndependenceDay
            or isFreedomDemocracyDay
            or isChristmasEve
            or isChristmasDay
            or isStStephensDay
            or isGoodFriday
            or isEasterMonday,
    
    // Function to determine if a date is a Slovak holiday
    IsSlovakHoliday = (date as date, year as number, month as number, day as number) as logical =>
        let
            isNewYear = month = 1 and day = 1,
            isEpiphany = year >= 1993 and month = 1 and day = 6,
            isLabourDay = month = 5 and day = 1,
            isVictoryDay = month = 5 and day = 8,
            isStCyrilMethodiusDay = month = 7 and day = 5,
            isSNPDay = month = 8 and day = 29,
            isConstitutionDay = year >= 1994 and month = 9 and day = 1,
            isOurLadyOfSorrows = year >= 1994 and month = 9 and day = 15,
            isIndependenceDay = year <= 1992 and month = 10 and day = 28,
            isAllSaintsDay = month = 11 and day = 1,
            isFreedomDemocracyDay = year >= 2000 and month = 11 and day = 17,
            isChristmasEve = month = 12 and day = 24,
            isChristmasDay = month = 12 and day = 25,
            isStStephensDay = month = 12 and day = 26,
            isGoodFriday = date = CalculateGoodFriday(year) and year >= 2016,
            isEasterMonday = date = CalculateEasterMonday(year)
        in
            isNewYear
            or isEpiphany
            or isLabourDay
            or isVictoryDay
            or isStCyrilMethodiusDay
            or isSNPDay
            or isConstitutionDay
            or isOurLadyOfSorrows
            or isIndependenceDay
            or isAllSaintsDay
            or isFreedomDemocracyDay
            or isChristmasEve
            or isChristmasDay
            or isStStephensDay
            or isGoodFriday
            or isEasterMonday,

    // Main script
    #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table", {{"Column1", "Date"}}),
    #"Changed type of Date" = Table.TransformColumnTypes(#"Renamed Columns", {{"Date", type date}}),
    #"Inserted YYYYMMDD" = Table.AddColumn(
            #"Changed type of Date",
            "YYYYMMDD",
            each
                Text.From(Date.Year([Date]))
                    & Text.PadStart(Text.From(Date.Month([Date])), 2, "0")
                    & Text.PadStart(Text.From(Date.Day([Date])), 2, "0")
        ),
    #"Changed Type of YYYYMMDD" = Table.TransformColumnTypes(#"Inserted YYYYMMDD", {{"YYYYMMDD", Int64.Type}}),
    #"Inserted Year" = Table.AddColumn(#"Changed Type of YYYYMMDD", "Year", each Date.Year([Date]), Int64.Type),
    #"Inserted Start of Year" = Table.AddColumn(
            #"Inserted Year", "Start of Year", each Date.StartOfYear([Date]), type date
        ),
    #"Inserted End of Year" = Table.AddColumn(
            #"Inserted Start of Year", "End of Year", each Date.EndOfYear([Date]), type date
        ),
    #"Inserted Month" = Table.AddColumn(#"Inserted End of Year", "Month", each Date.Month([Date]), Int64.Type),
    #"Inserted Start of Month" = Table.AddColumn(
            #"Inserted Month", "Start of Month", each Date.StartOfMonth([Date]), type date
        ),
    #"Inserted End of Month" = Table.AddColumn(
            #"Inserted Start of Month", "End of Month", each Date.EndOfMonth([Date]), type date
        ),
    #"Inserted Days in Month" = Table.AddColumn(
            #"Inserted End of Month", "Days in Month", each Date.DaysInMonth([Date]), Int64.Type
        ),
    #"Inserted Day" = Table.AddColumn(#"Inserted Days in Month", "Day", each Date.Day([Date]), Int64.Type),
    #"Inserted Day Name" = Table.AddColumn(#"Inserted Day", "Day Name", each Date.DayOfWeekName([Date]), type text),
    #"Inserted Day of Week" = Table.AddColumn(
            #"Inserted Day Name", "Day of Week", each Date.DayOfWeek([Date], firstDayofWeek) + 1, Int64.Type
        ),
    #"Inserted Day of Year" = Table.AddColumn(
            #"Inserted Day of Week", "Day of Year", each Date.DayOfYear([Date]), Int64.Type
        ),
    #"Inserted Month Name" = Table.AddColumn(
            #"Inserted Day of Year", "Month Name", each Date.MonthName([Date]), type text
        ),
    #"Inserted Quarter" = Table.AddColumn(
            #"Inserted Month Name", "Quarter", each Date.QuarterOfYear([Date]), Int64.Type
        ),
    #"Inserted Start of Quarter" = Table.AddColumn(
            #"Inserted Quarter", "Start of Quarter", each Date.StartOfQuarter([Date]), type date
        ),
    #"Inserted End of Quarter" = Table.AddColumn(
            #"Inserted Start of Quarter", "End of Quarter", each Date.EndOfQuarter([Date]), type date
        ),
    #"Inserted Week of Year" = Table.AddColumn(
            #"Inserted End of Quarter", "Week of Year", each Date.WeekOfYear([Date], firstDayofWeek), Int64.Type
        ),
    #"Inserted Week of Month" = Table.AddColumn(
            #"Inserted Week of Year", "Week of Month", each Date.WeekOfMonth([Date], firstDayofWeek), Int64.Type
        ),
    #"Inserted Start of Week" = Table.AddColumn(
            #"Inserted Week of Month", "Start of Week", each Date.StartOfWeek([Date], firstDayofWeek), type date
        ),
    #"Inserted End of Week" = Table.AddColumn(
            #"Inserted Start of Week", "End of Week", each Date.EndOfWeek([Date], firstDayofWeek), type date
        ),
    #"Inserted Age" = Table.AddColumn(#"Inserted End of Week", "Age", each [Date] - Today, type duration),
    #"Extracted Days" = Table.TransformColumns(#"Inserted Age", {{"Age", Duration.Days, Int64.Type}}),
    #"Renamed Day Offset" = Table.RenameColumns(#"Extracted Days", {{"Age", "Day Offset"}}),
    #"Added Month Offset" = Table.AddColumn(
            #"Renamed Day Offset", "Month Offset", each (([Year] - Date.Year(Today)) * 12) + ([Month] - Date.Month(Today))
        ),
    #"Changed Type of Month Offset" = Table.TransformColumnTypes(
            #"Added Month Offset", {{"Month Offset", Int64.Type}}
        ),
    #"Added Year Offset" = Table.AddColumn(
            #"Changed Type of Month Offset", "Year Offset", each [Year] - Date.Year(Today)
        ),
    #"Changed Type of Year Offset" = Table.TransformColumnTypes(#"Added Year Offset", {{"Year Offset", Int64.Type}}),
    #"Added Quarter Offset" = Table.AddColumn(
            #"Changed Type of Year Offset",
            "Quarter Offset",
            each (([Year] - Date.Year(Today)) * 4) + ([Quarter] - Date.QuarterOfYear(Today))
        ),
    #"Changed Type of Quarter Offset" = Table.TransformColumnTypes(
            #"Added Quarter Offset", {{"Quarter Offset", Int64.Type}}
        ),
    #"Added MMM YYYY" = Table.AddColumn(
            #"Changed Type of Quarter Offset", "MMM YYYY", each Date.ToText([Date], "MMM yyyy")
        ),
    #"Changed Type of MMM YYYY" = Table.TransformColumnTypes(#"Added MMM YYYY", {{"MMM YYYY", type text}}),
    #"Added YYYYMM" = Table.AddColumn(#"Changed Type of MMM YYYY", "YYYYMM", each Date.ToText([Date], "yyyyMM")),
    #"Changed Type of YYYYMM" = Table.TransformColumnTypes(#"Added YYYYMM", {{"YYYYMM", type text}}),
    // Add Czech holidays column (valid for dates after 1970)
    #"Added Czech holidays" = Table.AddColumn(
            #"Changed Type of YYYYMM", "isCzechHoliday", each IsCzechHoliday([Date], [Year], [Month], [Day])
        ),
    #"Changed Type of Czech Holidays" = Table.TransformColumnTypes(
            #"Added Czech holidays", {{"isCzechHoliday", type logical}}
        ),
    // Add Slovak holidays column (valid for dates after 1970)
    #"Added Slovak holidays" = Table.AddColumn(
            #"Changed Type of Czech Holidays", "isSlovakHoliday", each IsSlovakHoliday([Date], [Year], [Month], [Day])
        ),
    #"Changed Type of Slovak Holidays" = Table.TransformColumnTypes(
            #"Added Slovak holidays", {{"isSlovakHoliday", type logical}}
        ),
    #"Added isWeekend" = Table.AddColumn(
            #"Changed Type of Slovak Holidays", "isWeekend", each
                if [Day of Week] = 6 or [Day of Week] = 7 then
                    true
                else
                    false
        ),
    #"Chandeg Type of isWeekend" = Table.TransformColumnTypes(#"Added isWeekend", {{"isWeekend", type logical}})
in
    #"Chandeg Type of isWeekend"
