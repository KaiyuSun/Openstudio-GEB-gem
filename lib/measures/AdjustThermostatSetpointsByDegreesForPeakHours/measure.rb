# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

# start the measure
require 'json'
class AdjustThermostatSetpointsByDegreesForPeakHours < OpenStudio::Measure::ModelMeasure
  # setup OpenStudio units that we will need
  TEMP_IP_UNIT = OpenStudio.createUnit('F').get
  TEMP_SI_UNIT = OpenStudio.createUnit('C').get
  
  # define the name that a user will see
  def name
    return 'Adjust thermostat setpoint by degrees for peak hours'
  end

  # human readable description
  def description
    return 'This measure adjusts heating and cooling setpoints by a user-specified number of degrees and a user-specified time period. This is applied throughout the entire building.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This measure will clone all of the schedules that are used as heating and cooling setpoints for thermal zones. The clones are hooked up to the thermostat in place of the original schedules. Then the schedules are adjusted by the specified values during a specified time period. There is a checkbox to determine if the thermostat for design days should be altered.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # make an argument for adjustment to heating setpoint
    heating_adjustment = OpenStudio::Measure::OSArgument.makeDoubleArgument('heating_adjustment', true)
    heating_adjustment.setDisplayName('Degrees Fahrenheit to Adjust heating Setpoint By')
    heating_adjustment.setDefaultValue(-2.0)
    args << heating_adjustment

    heating_start_date1 = OpenStudio::Ruleset::OSArgument.makeStringArgument('heating_start_date1', true)
    heating_start_date1.setDisplayName('First start date for heating setpoint adjustment')
    heating_start_date1.setDescription('In MM-DD format')
    heating_start_date1.setDefaultValue('01-01')
    args << heating_start_date1
    heating_end_date1 = OpenStudio::Ruleset::OSArgument.makeStringArgument('heating_end_date1', true)
    heating_end_date1.setDisplayName('First end date for heating setpoint adjustment')
    heating_end_date1.setDescription('In MM-DD format')
    heating_end_date1.setDefaultValue('03-31')
    args << heating_end_date1

    heating_start_date2 = OpenStudio::Ruleset::OSArgument.makeStringArgument('heating_start_date2', false)
    heating_start_date2.setDisplayName('Second start date for heating setpoint adjustment (optional)')
    heating_start_date2.setDescription('Specify a date in MM-DD format if you want a second season of heating setpoint adjustment; leave blank if not needed.')
    heating_start_date2.setDefaultValue('')
    args << heating_start_date2
    heating_end_date2 = OpenStudio::Ruleset::OSArgument.makeStringArgument('heating_end_date2', false)
    heating_end_date2.setDisplayName('Second end date for heating setpoint adjustment')
    heating_end_date2.setDescription('Specify a date in MM-DD format if you want a second season of heating setpoint adjustment; leave blank if not needed. If either the start or end date is blank, the period is considered not used.')
    heating_end_date2.setDefaultValue('')
    args << heating_end_date2

    heating_start_date3 = OpenStudio::Ruleset::OSArgument.makeStringArgument('heating_start_date3', false)
    heating_start_date3.setDisplayName('Third start date for heating setpoint adjustment (optional)')
    heating_start_date3.setDescription('Specify a date in MM-DD format if you want a third season of heating setpoint adjustment; leave blank if not needed.')
    heating_start_date3.setDefaultValue('')
    args << heating_start_date3
    heating_end_date3 = OpenStudio::Ruleset::OSArgument.makeStringArgument('heating_end_date3', false)
    heating_end_date3.setDisplayName('Third end date for heating setpoint adjustment')
    heating_end_date3.setDescription('Specify a date in MM-DD format if you want a third season of heating setpoint adjustment; leave blank if not needed. If either the start or end date is blank, the period is considered not used.')
    heating_end_date3.setDefaultValue('')
    args << heating_end_date3

    heating_start_date4 = OpenStudio::Ruleset::OSArgument.makeStringArgument('heating_start_date4', false)
    heating_start_date4.setDisplayName('Fourth start date for heating setpoint adjustment (optional)')
    heating_start_date4.setDescription('Specify a date in MM-DD format if you want a fourth season of heating setpoint adjustment; leave blank if not needed.')
    heating_start_date4.setDefaultValue('')
    args << heating_start_date4
    heating_end_date4 = OpenStudio::Ruleset::OSArgument.makeStringArgument('heating_end_date4', false)
    heating_end_date4.setDisplayName('Fourth end date for heating setpoint adjustment')
    heating_end_date4.setDescription('Specify a date in MM-DD format if you want a fourth season of heating setpoint adjustment; leave blank if not needed. If either the start or end date is blank, the period is considered not used.')
    heating_end_date4.setDefaultValue('')
    args << heating_end_date4

    heating_start_date5 = OpenStudio::Ruleset::OSArgument.makeStringArgument('heating_start_date5', false)
    heating_start_date5.setDisplayName('Fifth start date for heating setpoint adjustment (optional)')
    heating_start_date5.setDescription('Specify a date in MM-DD format if you want a fifth season of heating setpoint adjustment; leave blank if not needed.')
    heating_start_date5.setDefaultValue('')
    args << heating_start_date5
    heating_end_date5 = OpenStudio::Ruleset::OSArgument.makeStringArgument('heating_end_date5', false)
    heating_end_date5.setDisplayName('Fifth end date for heating setpoint adjustment')
    heating_end_date5.setDescription('Specify a date in MM-DD format if you want a fifth season of heating setpoint adjustment; leave blank if not needed. If either the start or end date is blank, the period is considered not used.')
    heating_end_date5.setDefaultValue('')
    args << heating_end_date5

    heating_start_time1 = OpenStudio::Measure::OSArgument.makeStringArgument('heating_start_time1', true)
    heating_start_time1.setDisplayName('Start time of heating setpoint adjustment for the first season')
    heating_start_time1.setDescription('In HH:MM:SS format')
    heating_start_time1.setDefaultValue('17:00:00')
    args << heating_start_time1
    heating_end_time1 = OpenStudio::Measure::OSArgument.makeStringArgument('heating_end_time1', true)
    heating_end_time1.setDisplayName('End time of heating setpoint adjustment for the first season')
    heating_end_time1.setDescription('In HH:MM:SS format')
    heating_end_time1.setDefaultValue('21:00:00')
    args << heating_end_time1

    heating_start_time2 = OpenStudio::Measure::OSArgument.makeStringArgument('heating_start_time2', false)
    heating_start_time2.setDisplayName('Start time of heating setpoint adjustment for the second season (optional)')
    heating_start_time2.setDescription('In HH:MM:SS format')
    heating_start_time2.setDefaultValue('')
    args << heating_start_time2
    heating_end_time2 = OpenStudio::Measure::OSArgument.makeStringArgument('heating_end_time2', false)
    heating_end_time2.setDisplayName('End time of heating setpoint adjustment for the second season (optional)')
    heating_end_time2.setDescription('In HH:MM:SS format')
    heating_end_time2.setDefaultValue('')
    args << heating_end_time2

    heating_start_time3 = OpenStudio::Measure::OSArgument.makeStringArgument('heating_start_time3', false)
    heating_start_time3.setDisplayName('Start time of heating setpoint adjustment for the third season (optional)')
    heating_start_time3.setDescription('In HH:MM:SS format')
    heating_start_time3.setDefaultValue('')
    args << heating_start_time3
    heating_end_time3 = OpenStudio::Measure::OSArgument.makeStringArgument('heating_end_time3', false)
    heating_end_time3.setDisplayName('End time of heating setpoint adjustment for the third season (optional)')
    heating_end_time3.setDescription('In HH:MM:SS format')
    heating_end_time3.setDefaultValue('')
    args << heating_end_time3

    heating_start_time4 = OpenStudio::Measure::OSArgument.makeStringArgument('heating_start_time4', false)
    heating_start_time4.setDisplayName('Start time of heating setpoint adjustment for the fourth season (optional)')
    heating_start_time4.setDescription('In HH:MM:SS format')
    heating_start_time4.setDefaultValue('')
    args << heating_start_time4
    heating_end_time4 = OpenStudio::Measure::OSArgument.makeStringArgument('heating_end_time4', false)
    heating_end_time4.setDisplayName('End time of heating setpoint adjustment for the fourth season (optional)')
    heating_end_time4.setDescription('In HH:MM:SS format')
    heating_end_time4.setDefaultValue('')
    args << heating_end_time4

    heating_start_time5 = OpenStudio::Measure::OSArgument.makeStringArgument('heating_start_time5', false)
    heating_start_time5.setDisplayName('Start time of heating setpoint adjustment for the fifth season (optional)')
    heating_start_time5.setDescription('In HH:MM:SS format')
    heating_start_time5.setDefaultValue('')
    args << heating_start_time5
    heating_end_time5 = OpenStudio::Measure::OSArgument.makeStringArgument('heating_end_time5', false)
    heating_end_time5.setDisplayName('End time of heating setpoint adjustment for the fifth season (optional)')
    heating_end_time5.setDescription('In HH:MM:SS format')
    heating_end_time5.setDefaultValue('')
    args << heating_end_time5


    # make an argument for adjustment to cooling setpoint
    cooling_adjustment = OpenStudio::Measure::OSArgument.makeDoubleArgument('cooling_adjustment', true)
    cooling_adjustment.setDisplayName('Degrees Fahrenheit to Adjust Cooling Setpoint By')
    cooling_adjustment.setDefaultValue(5.0)
    args << cooling_adjustment

    cooling_start_date1 = OpenStudio::Ruleset::OSArgument.makeStringArgument('cooling_start_date1', true)
    cooling_start_date1.setDisplayName('First start date for cooling setpoint adjustment')
    cooling_start_date1.setDescription('In MM-DD format')
    cooling_start_date1.setDefaultValue('06-01')
    args << cooling_start_date1
    cooling_end_date1 = OpenStudio::Ruleset::OSArgument.makeStringArgument('cooling_end_date1', true)
    cooling_end_date1.setDisplayName('First end date for cooling setpoint adjustment')
    cooling_end_date1.setDescription('In MM-DD format')
    cooling_end_date1.setDefaultValue('09-30')
    args << cooling_end_date1

    cooling_start_date2 = OpenStudio::Ruleset::OSArgument.makeStringArgument('cooling_start_date2', false)
    cooling_start_date2.setDisplayName('Second start date for cooling setpoint adjustment (optional)')
    cooling_start_date2.setDescription('Specify a date in MM-DD format if you want a second season of cooling setpoint adjustment; leave blank if not needed.')
    cooling_start_date2.setDefaultValue('')
    args << cooling_start_date2
    cooling_end_date2 = OpenStudio::Ruleset::OSArgument.makeStringArgument('cooling_end_date2', false)
    cooling_end_date2.setDisplayName('Second end date for cooling setpoint adjustment')
    cooling_end_date2.setDescription('Specify a date in MM-DD format if you want a second season of cooling setpoint adjustment; leave blank if not needed. If either the start or end date is blank, the period is considered not used.')
    cooling_end_date2.setDefaultValue('')
    args << cooling_end_date2

    cooling_start_date3 = OpenStudio::Ruleset::OSArgument.makeStringArgument('cooling_start_date3', false)
    cooling_start_date3.setDisplayName('Third start date for cooling setpoint adjustment (optional)')
    cooling_start_date3.setDescription('Specify a date in MM-DD format if you want a third season of cooling setpoint adjustment; leave blank if not needed.')
    cooling_start_date3.setDefaultValue('')
    args << cooling_start_date3
    cooling_end_date3 = OpenStudio::Ruleset::OSArgument.makeStringArgument('cooling_end_date3', false)
    cooling_end_date3.setDisplayName('Third end date for cooling setpoint adjustment')
    cooling_end_date3.setDescription('Specify a date in MM-DD format if you want a third season of cooling setpoint adjustment; leave blank if not needed. If either the start or end date is blank, the period is considered not used.')
    cooling_end_date3.setDefaultValue('')
    args << cooling_end_date3

    cooling_start_date4 = OpenStudio::Ruleset::OSArgument.makeStringArgument('cooling_start_date4', false)
    cooling_start_date4.setDisplayName('Fourth start date for cooling setpoint adjustment (optional)')
    cooling_start_date4.setDescription('Specify a date in MM-DD format if you want a fourth season of cooling setpoint adjustment; leave blank if not needed.')
    cooling_start_date4.setDefaultValue('')
    args << cooling_start_date4
    cooling_end_date4 = OpenStudio::Ruleset::OSArgument.makeStringArgument('cooling_end_date4', false)
    cooling_end_date4.setDisplayName('Fourth end date for cooling setpoint adjustment')
    cooling_end_date4.setDescription('Specify a date in MM-DD format if you want a fourth season of cooling setpoint adjustment; leave blank if not needed. If either the start or end date is blank, the period is considered not used.')
    cooling_end_date4.setDefaultValue('')
    args << cooling_end_date4

    cooling_start_date5 = OpenStudio::Ruleset::OSArgument.makeStringArgument('cooling_start_date5', false)
    cooling_start_date5.setDisplayName('Fifth start date for cooling setpoint adjustment (optional)')
    cooling_start_date5.setDescription('Specify a date in MM-DD format if you want a fifth season of cooling setpoint adjustment; leave blank if not needed.')
    cooling_start_date5.setDefaultValue('')
    args << cooling_start_date5
    cooling_end_date5 = OpenStudio::Ruleset::OSArgument.makeStringArgument('cooling_end_date5', false)
    cooling_end_date5.setDisplayName('Fifth end date for cooling setpoint adjustment')
    cooling_end_date5.setDescription('Specify a date in MM-DD format if you want a fifth season of cooling setpoint adjustment; leave blank if not needed. If either the start or end date is blank, the period is considered not used.')
    cooling_end_date5.setDefaultValue('')
    args << cooling_end_date5

    cooling_start_time1 = OpenStudio::Measure::OSArgument.makeStringArgument('cooling_start_time1', true)
    cooling_start_time1.setDisplayName('Start time of cooling setpoint adjustment for the first season')
    cooling_start_time1.setDescription('In HH:MM:SS format')
    cooling_start_time1.setDefaultValue('17:00:00')
    args << cooling_start_time1
    cooling_end_time1 = OpenStudio::Measure::OSArgument.makeStringArgument('cooling_end_time1', true)
    cooling_end_time1.setDisplayName('End time of cooling setpoint adjustment for the first season')
    cooling_end_time1.setDescription('In HH:MM:SS format')
    cooling_end_time1.setDefaultValue('21:00:00')
    args << cooling_end_time1

    cooling_start_time2 = OpenStudio::Measure::OSArgument.makeStringArgument('cooling_start_time2', false)
    cooling_start_time2.setDisplayName('Start time of cooling setpoint adjustment for the second season (optional)')
    cooling_start_time2.setDescription('In HH:MM:SS format')
    cooling_start_time2.setDefaultValue('')
    args << cooling_start_time2
    cooling_end_time2 = OpenStudio::Measure::OSArgument.makeStringArgument('cooling_end_time2', false)
    cooling_end_time2.setDisplayName('End time of cooling setpoint adjustment for the second season (optional)')
    cooling_end_time2.setDescription('In HH:MM:SS format')
    cooling_end_time2.setDefaultValue('')
    args << cooling_end_time2

    cooling_start_time3 = OpenStudio::Measure::OSArgument.makeStringArgument('cooling_start_time3', false)
    cooling_start_time3.setDisplayName('Start time of cooling setpoint adjustment for the third season (optional)')
    cooling_start_time3.setDescription('In HH:MM:SS format')
    cooling_start_time3.setDefaultValue('')
    args << cooling_start_time3
    cooling_end_time3 = OpenStudio::Measure::OSArgument.makeStringArgument('cooling_end_time3', false)
    cooling_end_time3.setDisplayName('End time of cooling setpoint adjustment for the third season (optional)')
    cooling_end_time3.setDescription('In HH:MM:SS format')
    cooling_end_time3.setDefaultValue('')
    args << cooling_end_time3

    cooling_start_time4 = OpenStudio::Measure::OSArgument.makeStringArgument('cooling_start_time4', false)
    cooling_start_time4.setDisplayName('Start time of cooling setpoint adjustment for the fourth season (optional)')
    cooling_start_time4.setDescription('In HH:MM:SS format')
    cooling_start_time4.setDefaultValue('')
    args << cooling_start_time4
    cooling_end_time4 = OpenStudio::Measure::OSArgument.makeStringArgument('cooling_end_time4', false)
    cooling_end_time4.setDisplayName('End time of cooling setpoint adjustment for the fourth season (optional)')
    cooling_end_time4.setDescription('In HH:MM:SS format')
    cooling_end_time4.setDefaultValue('')
    args << cooling_end_time4

    cooling_start_time5 = OpenStudio::Measure::OSArgument.makeStringArgument('cooling_start_time5', false)
    cooling_start_time5.setDisplayName('Start time of cooling setpoint adjustment for the fifth season (optional)')
    cooling_start_time5.setDescription('In HH:MM:SS format')
    cooling_start_time5.setDefaultValue('')
    args << cooling_start_time5
    cooling_end_time5 = OpenStudio::Measure::OSArgument.makeStringArgument('cooling_end_time5', false)
    cooling_end_time5.setDisplayName('End time of cooling setpoint adjustment for the fifth season (optional)')
    cooling_end_time5.setDescription('In HH:MM:SS format')
    cooling_end_time5.setDefaultValue('')
    args << cooling_end_time5


    # Use alternative default start and end time for different climate zone
    alt_periods = OpenStudio::Measure::OSArgument.makeBoolArgument('alt_periods', true)
    alt_periods.setDisplayName('Use alternative default start and end time based on the state of the model from the Cambium load profile peak period?')
    alt_periods.setDescription('This will overwrite the start and end time and date provided by the user')
    alt_periods.setDefaultValue(false)
    args << alt_periods

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    heating_adjustment = runner.getDoubleArgumentValue('heating_adjustment', user_arguments)
    cooling_adjustment = runner.getDoubleArgumentValue('cooling_adjustment', user_arguments)
    heating_start_time1 = runner.getStringArgumentValue('heating_start_time1', user_arguments)
    heating_end_time1 = runner.getStringArgumentValue('heating_end_time1', user_arguments)
    heating_start_time2 = runner.getStringArgumentValue('heating_start_time2', user_arguments)
    heating_end_time2 = runner.getStringArgumentValue('heating_end_time2', user_arguments)
    heating_start_time3 = runner.getStringArgumentValue('heating_start_time3', user_arguments)
    heating_end_time3 = runner.getStringArgumentValue('heating_end_time3', user_arguments)
    heating_start_time4 = runner.getStringArgumentValue('heating_start_time4', user_arguments)
    heating_end_time4 = runner.getStringArgumentValue('heating_end_time4', user_arguments)
    heating_start_time5 = runner.getStringArgumentValue('heating_start_time5', user_arguments)
    heating_end_time5 = runner.getStringArgumentValue('heating_end_time5', user_arguments)
    heating_start_date1 = runner.getStringArgumentValue('heating_start_date1', user_arguments)
    heating_end_date1 = runner.getStringArgumentValue('heating_end_date1', user_arguments)
    heating_start_date2 = runner.getStringArgumentValue('heating_start_date2', user_arguments)
    heating_end_date2 = runner.getStringArgumentValue('heating_end_date2', user_arguments)
    heating_start_date3 = runner.getStringArgumentValue('heating_start_date3', user_arguments)
    heating_end_date3 = runner.getStringArgumentValue('heating_end_date4', user_arguments)
    heating_start_date4 = runner.getStringArgumentValue('heating_start_date4', user_arguments)
    heating_end_date4 = runner.getStringArgumentValue('heating_end_date5', user_arguments)
    heating_start_date5 = runner.getStringArgumentValue('heating_start_date5', user_arguments)
    heating_end_date5 = runner.getStringArgumentValue('heating_end_date5', user_arguments)
    cooling_start_time1 = runner.getStringArgumentValue('cooling_start_time1', user_arguments)
    cooling_end_time1 = runner.getStringArgumentValue('cooling_end_time1', user_arguments)
    cooling_start_time2 = runner.getStringArgumentValue('cooling_start_time2', user_arguments)
    cooling_end_time2 = runner.getStringArgumentValue('cooling_end_time2', user_arguments)
    cooling_start_time3 = runner.getStringArgumentValue('cooling_start_time3', user_arguments)
    cooling_end_time3 = runner.getStringArgumentValue('cooling_end_time3', user_arguments)
    cooling_start_time4 = runner.getStringArgumentValue('cooling_start_time4', user_arguments)
    cooling_end_time4 = runner.getStringArgumentValue('cooling_end_time4', user_arguments)
    cooling_start_time5 = runner.getStringArgumentValue('cooling_start_time5', user_arguments)
    cooling_end_time5 = runner.getStringArgumentValue('cooling_end_time5', user_arguments)
    cooling_start_date1 = runner.getStringArgumentValue('cooling_start_date1', user_arguments)
    cooling_end_date1 = runner.getStringArgumentValue('cooling_end_date1', user_arguments)
    cooling_start_date2 = runner.getStringArgumentValue('cooling_start_date2', user_arguments)
    cooling_end_date2 = runner.getStringArgumentValue('cooling_end_date2', user_arguments)
    cooling_start_date3 = runner.getStringArgumentValue('cooling_start_date3', user_arguments)
    cooling_end_date3 = runner.getStringArgumentValue('cooling_end_date4', user_arguments)
    cooling_start_date4 = runner.getStringArgumentValue('cooling_start_date4', user_arguments)
    cooling_end_date4 = runner.getStringArgumentValue('cooling_end_date5', user_arguments)
    cooling_start_date5 = runner.getStringArgumentValue('cooling_start_date5', user_arguments)
    cooling_end_date5 = runner.getStringArgumentValue('cooling_end_date5', user_arguments)
    alt_periods = runner.getBoolArgumentValue('alt_periods', user_arguments)


    # set the default start and end time based on climate zone
    if alt_periods
      state = model.getWeatherFile.stateProvinceRegion
      file = File.open(File.join(File.dirname(__FILE__), "../../../files/seasonal_shedding_peak_hours.json"))
      default_peak_periods = JSON.load(file)
      file.close
      peak_periods = default_peak_periods[state]
      cooling_start_time1 = heating_start_time1 = peak_periods["winter_peak_start"].split[1]
      cooling_end_time1 = heating_end_time1 = peak_periods["winter_peak_end"].split[1]
      cooling_start_time2 = heating_start_time2 = peak_periods["intermediate_peak_start"].split[1]
      cooling_end_time2 = heating_end_time2 = peak_periods["intermediate_peak_end"].split[1]
      cooling_start_time3 = heating_start_time3 = peak_periods["summer_peak_start"].split[1]
      cooling_end_time3 = heating_end_time3 = peak_periods["summer_peak_end"].split[1]
      cooling_start_time4 = heating_start_time4 = peak_periods["intermediate_peak_start"].split[1]
      cooling_end_time4 = heating_end_time4 = peak_periods["intermediate_peak_end"].split[1]
      cooling_start_time5 = heating_start_time5 = peak_periods["winter_peak_start"].split[1]
      cooling_end_time5 = heating_end_time5 = peak_periods["winter_peak_end"].split[1]
      cooling_start_date1 = heating_start_date1 = '01-01'
      cooling_end_date1 = heating_end_date1 = '03-31'
      cooling_start_date2 = heating_start_date2 = '04-01'
      cooling_end_date2 = heating_end_date2 = '05-31'
      cooling_start_date3 = heating_start_date3 = '06-01'
      cooling_end_date3 = heating_end_date3 = '09-30'
      cooling_start_date4 = heating_start_date4 = '10-01'
      cooling_end_date4 = heating_end_date4 = '11-30'
      cooling_start_date5 = heating_start_date5 = '12-01'
      cooling_end_date5 = heating_end_date5 = '12-31'
    end

    def validate_time_format(star_time, end_time, runner)
      time1 = /(\d\d):(\d\d):(\d\d)/.match(star_time)
      time2 = /(\d\d):(\d\d):(\d\d)/.match(end_time)
      if time1 and time2
        os_starttime = OpenStudio::Time.new(star_time)
        os_endtime = OpenStudio::Time.new(end_time)
        if star_time >= end_time
          runner.registerError('The start time needs to be earlier than the end time.')
          return false
        else
          return os_starttime, os_endtime
        end
      else
        runner.registerError('The provided time is not in HH-MM-SS format.')
        return false
      end
    end

    def validate_date_format(start_date1, end_date1, runner)
      smd = /(\d\d)-(\d\d)/.match(start_date1)
      emd = /(\d\d)-(\d\d)/.match(end_date1)
      if smd.nil? or emd.nil?
        runner.registerError('The provided date is not in MM-DD format.')
        return false
      else
        start_month = smd[1].to_i
        start_day = smd[2].to_i
        end_month = emd[1].to_i
        end_day = emd[2].to_i
        if start_date1 > end_date1
          runner.registerError('The start date cannot be later date the end time.')
          return false
        else
          os_start_date = OpenStudio::Date.new(OpenStudio::MonthOfYear.new(start_month), start_day)
          os_end_date = OpenStudio::Date.new(OpenStudio::MonthOfYear.new(end_month), end_day)
          return os_start_date, os_end_date
        end
      end
    end

    # First time period for heating
    heating_time_result1 = validate_time_format(heating_start_time1, heating_end_time1, runner)
    if heating_time_result1
      heating_shift_time_start1, heating_shift_time_end1 = heating_time_result1
    else
      runner.registerError('The required time period for the adjustment is not in correct format!')
      return false
    end
    # The other optional time periods
    heating_shift_time_start2,heating_shift_time_end2,heating_shift_time_start3,heating_shift_time_end3,heating_shift_time_start4,heating_shift_time_end4,heating_shift_time_start5,heating_shift_time_end5 = [nil]*8
    if (not heating_start_time2.empty?) and (not heating_end_time2.empty?)
      heating_time_result2 = validate_time_format(heating_start_time2, heating_end_time2, runner)
      if heating_time_result2
        heating_shift_time_start2, heating_shift_time_end2 = heating_time_result2
      end
    end
    if (not heating_start_time3.empty?) and (not heating_end_time3.empty?)
      heating_time_result3 = validate_time_format(heating_start_time3, heating_end_time3, runner)
      if heating_time_result3
        heating_shift_time_start3, heating_shift_time_end3 = heating_time_result3
      end
    end
    if (not heating_start_time4.empty?) and (not heating_end_time4.empty?)
      heating_time_result4 = validate_time_format(heating_start_time4, heating_end_time4, runner)
      if heating_time_result4
        heating_shift_time_start4, heating_shift_time_end4 = heating_time_result4
      end
    end
    if (not heating_start_time5.empty?) and (not heating_end_time5.empty?)
      heating_time_result5 = validate_time_format(heating_start_time5, heating_end_time5, runner)
      if heating_time_result5
        heating_shift_time_start5, heating_shift_time_end5 = heating_time_result5
      end
    end

    # First time period for cooling
    cooling_time_result1 = validate_time_format(cooling_start_time1, cooling_end_time1, runner)
    if cooling_time_result1
      cooling_shift_time_start1, cooling_shift_time_end1 = cooling_time_result1
    else
      runner.registerError('The required time period for the adjustment is not in correct format!')
      return false
    end
    # The other optional time periods
    cooling_shift_time_start2,cooling_shift_time_end2,cooling_shift_time_start3,cooling_shift_time_end3,cooling_shift_time_start4,cooling_shift_time_end4,cooling_shift_time_start5,cooling_shift_time_end5 = [nil]*8
    if (not cooling_start_time2.empty?) and (not cooling_end_time2.empty?)
      cooling_time_result2 = validate_time_format(cooling_start_time2, cooling_end_time2, runner)
      if cooling_time_result2
        cooling_shift_time_start2, cooling_shift_time_end2 = cooling_time_result2
      end
    end
    if (not cooling_start_time3.empty?) and (not cooling_end_time3.empty?)
      cooling_time_result3 = validate_time_format(cooling_start_time3, cooling_end_time3, runner)
      if cooling_time_result3
        cooling_shift_time_start3, cooling_shift_time_end3 = cooling_time_result3
      end
    end
    if (not cooling_start_time4.empty?) and (not cooling_end_time4.empty?)
      cooling_time_result4 = validate_time_format(cooling_start_time4, cooling_end_time4, runner)
      if cooling_time_result4
        cooling_shift_time_start4, cooling_shift_time_end4 = cooling_time_result4
      end
    end
    if (not cooling_start_time5.empty?) and (not cooling_end_time5.empty?)
      cooling_time_result5 = validate_time_format(cooling_start_time5, cooling_end_time5, runner)
      if cooling_time_result5
        cooling_shift_time_start5, cooling_shift_time_end5 = cooling_time_result5
      end
    end

    # First date period
    heating_date_result1 = validate_date_format(heating_start_date1, heating_end_date1, runner)
    if heating_date_result1
      os_heating_start_date1, os_heating_end_date1 = heating_date_result1
    else
      runner.registerError('The required date period for the heating setpoint adjustment is not in correct format!')
      return false
    end
    # Other optional date period
    os_heating_start_date2, os_heating_end_date2, os_heating_start_date3, os_heating_end_date3, os_heating_start_date4, os_heating_end_date4, os_heating_start_date5, os_heating_end_date5 = [nil]*8
    if (not heating_start_date2.empty?) and (not heating_end_date2.empty?)
      heating_date_result2 = validate_date_format(heating_start_date2, heating_end_date2, runner)
      if heating_date_result2
        os_heating_start_date2, os_heating_end_date2 = heating_date_result2
      end
    end

    if (not heating_start_date3.empty?) and (not heating_end_date3.empty?)
      heating_date_result3 = validate_date_format(heating_start_date3, heating_end_date3, runner)
      if heating_date_result3
        os_heating_start_date3, os_heating_end_date3 = heating_date_result3
      end
    end

    if (not heating_start_date4.empty?) and (not heating_end_date4.empty?)
      heating_date_result4 = validate_date_format(heating_start_date4, heating_end_date4, runner)
      if heating_date_result4
        os_heating_start_date4, os_heating_end_date4 = heating_date_result4
      end
    end

    if (not heating_start_date5.empty?) and (not heating_end_date5.empty?)
      heating_date_result5 = validate_date_format(heating_start_date5, heating_end_date5, runner)
      if heating_date_result5
        os_heating_start_date5, os_heating_end_date5 = heating_date_result5
      end
    end

    # First date period
    cooling_date_result1 = validate_date_format(cooling_start_date1, cooling_end_date1, runner)
    if cooling_date_result1
      os_cooling_start_date1, os_cooling_end_date1 = cooling_date_result1
    else
      runner.registerError('The required date period for the cooling setpoint adjustment is not in correct format!')
      return false
    end
    # Other optional date period
    os_cooling_start_date2, os_cooling_end_date2, os_cooling_start_date3, os_cooling_end_date3, os_cooling_start_date4, os_cooling_end_date4, os_cooling_start_date5, os_cooling_end_date5 = [nil]*8
    if (not cooling_start_date2.empty?) and (not cooling_end_date2.empty?)
      cooling_date_result2 = validate_date_format(cooling_start_date2, cooling_end_date2, runner)
      if cooling_date_result2
        os_cooling_start_date2, os_cooling_end_date2 = cooling_date_result2
      end
    end

    if (not cooling_start_date3.empty?) and (not cooling_end_date3.empty?)
      cooling_date_result3 = validate_date_format(cooling_start_date3, cooling_end_date3, runner)
      if cooling_date_result3
        os_cooling_start_date3, os_cooling_end_date3 = cooling_date_result3
      end
    end

    if (not cooling_start_date4.empty?) and (not cooling_end_date4.empty?)
      cooling_date_result4 = validate_date_format(cooling_start_date4, cooling_end_date4, runner)
      if cooling_date_result4
        os_cooling_start_date4, os_cooling_end_date4 = cooling_date_result4
      end
    end

    if (not cooling_start_date5.empty?) and (not cooling_end_date5.empty?)
      cooling_date_result5 = validate_date_format(cooling_start_date5, cooling_end_date5, runner)
      if cooling_date_result5
        os_cooling_start_date5, os_cooling_end_date5 = cooling_date_result5
      end
    end

    # ruby test to see if first charter of string is uppercase letter
    if cooling_adjustment < 0
      runner.registerWarning('Lowering the cooling setpoint will increase energy use. Please double check your input.')
    elsif cooling_adjustment.abs > 500
      runner.registerError("#{cooling_adjustment} is larger than typical setpoint adjustment. Please double check your input.")
      return false
    elsif cooling_adjustment.abs > 50
      runner.registerWarning("#{cooling_adjustment} is larger than typical setpoint adjustment. Please double check your input.")
    end
    if heating_adjustment > 0
      runner.registerWarning('Raising the heating setpoint will increase energy use. Please double check your input.')
    elsif heating_adjustment.abs > 500
      runner.registerError("#{heating_adjustment} is larger than typical setpoint adjustment. Please double check your input.")
      return false
    elsif heating_adjustment.abs > 50
      runner.registerWarning("#{heating_adjustment} is larger than typical setpoint adjustment. Please double check your input.")
    end

    # define starting units
    cooling_adjustment_ip = OpenStudio::Quantity.new(cooling_adjustment, TEMP_IP_UNIT)
    heating_adjustment_ip = OpenStudio::Quantity.new(heating_adjustment, TEMP_IP_UNIT)

    # push schedules to hash to avoid making unnecessary duplicates
    clg_set_schs = {}
    htg_set_schs = {}
    # get spaces
    thermostats = model.getThermostatSetpointDualSetpoints
    thermostats.each do |thermostat|
      # setup new cooling setpoint schedule
      clg_set_sch = thermostat.coolingSetpointTemperatureSchedule

      if !clg_set_sch.empty?
        old_schedule_name = clg_set_sch.get.name.to_s
        # clone if not already in hash
        if clg_set_schs.key?(old_schedule_name)
          new_clg_set_sch = clg_set_schs[old_schedule_name]
        else
          new_clg_set_sch = clg_set_sch.get.clone(model)
          new_clg_set_sch = new_clg_set_sch.to_Schedule.get
          new_clg_set_sch.setName("#{old_schedule_name} adjusted by #{cooling_adjustment_ip}F")
          runner.registerInfo("Cooling schedule #{old_schedule_name} is cloned to #{new_clg_set_sch.name.to_s}")
          # add to the hash
          clg_set_schs[old_schedule_name] = new_clg_set_sch
        end
        # hook up cloned schedule to thermostat
        thermostat.setCoolingSetpointTemperatureSchedule(new_clg_set_sch)
      else
        runner.registerWarning("Thermostat '#{thermostat.name}' doesn't have a cooling setpoint schedule")
      end

      # setup new heating setpoint schedule
      htg_set_sch = thermostat.heatingSetpointTemperatureSchedule
      if !htg_set_sch.empty?
        old_schedule_name = htg_set_sch.get.name.to_s
        # clone of not already in hash
        if htg_set_schs.key?(old_schedule_name)
          new_htg_set_sch = htg_set_schs[old_schedule_name]
        else
          new_htg_set_sch = htg_set_sch.get.clone(model)
          new_htg_set_sch = new_htg_set_sch.to_Schedule.get
          new_htg_set_sch.setName("#{old_schedule_name} adjusted by #{heating_adjustment_ip}")
          runner.registerInfo("Cooling schedule #{old_schedule_name} is cloned to #{new_htg_set_sch.name.to_s}")
          # add to the hash
          htg_set_schs[old_schedule_name] = new_htg_set_sch
        end
        # hook up clone to thermostat
        thermostat.setHeatingSetpointTemperatureSchedule(new_htg_set_sch)
      else
        runner.registerWarning("Thermostat '#{thermostat.name}' doesn't have a heating setpoint schedule.")
      end
    end

    # puts "clg_set_schs: #{clg_set_schs.inspect}"
    # puts "htg_set_schs: #{htg_set_schs.inspect}"

    # setting up variables to use for initial and final condition
    clg_sch_set_values = [] # may need to flatten this
    htg_sch_set_values = [] # may need to flatten this
    final_clg_sch_set_values = []
    final_htg_sch_set_values = []

    # consider issuing a warning if the model has un-conditioned thermal zones (no ideal air loads or hvac)
    zones = model.getThermalZones
    zones.each do |zone|
      # if you have a thermostat but don't have ideal air loads or zone equipment then issue a warning
      if !zone.thermostatSetpointDualSetpoint.empty? && !zone.useIdealAirLoads && (zone.equipment.size == 0)
        runner.registerWarning("Thermal zone '#{zone.name}' has a thermostat but does not appear to be conditioned.")
      end
    end

    # daylightsaving adjustment added in visualization, so deprecated here
    # # Check model's daylight saving period, if cooling period is within daylight saving period, shift the cooling start time and end time by one hour later
    # if model.getObjectsByType('OS:RunPeriodControl:DaylightSavingTime'.to_IddObjectType).size >= 1
    #   runperiodctrl_daylgtsaving = model.getRunPeriodControlDaylightSavingTime
    #   daylight_saving_startdate = runperiodctrl_daylgtsaving.startDate
    #   daylight_saving_enddate = runperiodctrl_daylgtsaving.endDate
    #   if summerStartDate >= OpenStudio::Date.new(daylight_saving_startdate.monthOfYear, daylight_saving_startdate.dayOfMonth, summerStartDate.year) && summerEndDate <= OpenStudio::Date.new(daylight_saving_enddate.monthOfYear, daylight_saving_enddate.dayOfMonth, summerStartDate.year)
    #     shift_time_cooling_start += OpenStudio::Time.new(0,1,0,0)
    #     shift_time_cooling_end += OpenStudio::Time.new(0,1,0,0)
    #   end
    # end

    applicable_flag = false
    optional_cooling_period_inputs = { "period2" => {"date_start"=>os_cooling_start_date2, "date_end"=>os_cooling_end_date2,
                                             "time_start"=>cooling_shift_time_start2, "time_end"=>cooling_shift_time_end2},
                               "period3" => {"date_start"=>os_cooling_start_date3, "date_end"=>os_cooling_end_date3,
                                             "time_start"=>cooling_shift_time_start3, "time_end"=>cooling_shift_time_end3},
                               "period4" => {"date_start"=>os_cooling_start_date4, "date_end"=>os_cooling_end_date4,
                                             "time_start"=>cooling_shift_time_start4, "time_end"=>cooling_shift_time_end4},
                               "period5" => {"date_start"=>os_cooling_start_date5, "date_end"=>os_cooling_end_date5,
                                             "time_start"=>cooling_shift_time_start5, "time_end"=>cooling_shift_time_end5} }
    # make cooling schedule adjustments and rename. Put in check to skip and warn if schedule not ruleset
    clg_set_schs.each do |old_sch_name, os_sch| # old name and new object for schedule
      if !os_sch.to_ScheduleRuleset.empty?
        schedule = os_sch.to_ScheduleRuleset.get
        rules = schedule.scheduleRules
        days_covered = Array.new(7, false)

        # TODO: when ruleset has multiple rules for each month or couple of months instead of a full year, should first see if the period overlaps with summer/winter
        if rules.length <= 0
          runner.registerWarning("Cooling setpoint schedule '#{old_sch_name}' is a ScheduleRuleSet, but has no ScheduleRules associated. It won't be altered by this measure.")
        else
          current_index = 0
          rules.each do |rule|
            rule_period1 = modify_rule_for_date_period(rule, os_cooling_start_date1, os_cooling_start_date1,
                                                       cooling_shift_time_start1, cooling_shift_time_end1,
                                                       cooling_adjustment_ip, model)
            if rule_period1
              applicable_flag = true
              checkDaysCovered(rule_period1, days_covered)
              runner.registerInfo("--------------- current days of week coverage: #{days_covered}")
              if schedule.setScheduleRuleIndex(rule_period1, current_index)
                current_index += 1
              else
                runner.registerError("Fail to set rule index for #{rule_period1.name.to_s}.")
              end
            end
            final_clg_sch_set_values << rule_period1.daySchedule.values

            optional_cooling_period_inputs.each do |period, period_inputs|
              os_start_date = period_inputs["date_start"]
              os_end_date = period_inputs["date_end"]
              shift_time_start = period_inputs["time_start"]
              shift_time_end = period_inputs["time_end"]
              if [os_start_date, os_end_date, shift_time_start, shift_time_end].all?
                rule_period = modify_rule_for_date_period(rule, os_start_date, os_end_date, shift_time_start, shift_time_end,
                                                          cooling_adjustment_ip, model)
                if rule_period
                  applicable_flag = true
                  if schedule.setScheduleRuleIndex(rule_period, current_index)
                    current_index += 1
                  else
                    runner.registerError("Fail to set rule index for #{rule_period.name.to_s}.")
                  end
                end
                runner.registerInfo("------------ cooling schedule #{old_sch_name} updated for #{rule_period.startDate.get} to #{rule_period.endDate.get}")
              end
            end
            # The original rule will be shifted to the currently lowest priority
            # Setting the rule to an existing index will automatically push all other rules after it down
            if schedule.setScheduleRuleIndex(rule, current_index)
              current_index += 1
            else
              runner.registerError("Fail to set rule index for #{rule.name.to_s}.")
            end
          end
        end

        default_day = schedule.defaultDaySchedule
        if days_covered.include?(false)
          runner.registerInfo("Some days use default day. Adding new scheduleRule from defaultDaySchedule for applicable date period.")
          modify_default_day_for_date_period(schedule, default_day, days_covered, os_cooling_start_date1, os_cooling_end_date1,
                                             cooling_shift_time_start1, cooling_shift_time_end1, cooling_adjustment_ip)
          optional_cooling_period_inputs.each do |period, period_inputs|
            os_start_date = period_inputs["date_start"]
            os_end_date = period_inputs["date_end"]
            shift_time_start = period_inputs["time_start"]
            shift_time_end = period_inputs["time_end"]
            if [os_start_date, os_end_date, shift_time_start, shift_time_end].all?
              modify_default_day_for_date_period(schedule, default_day, days_covered, os_start_date, os_end_date,
                                                 shift_time_start, shift_time_end, cooling_adjustment_ip)
              applicable_flag = true
            end
          end
          final_clg_sch_set_values << default_day.values
        end
        ######################################################################
      else
        runner.registerWarning("Schedule '#{old_sch_name}' isn't a ScheduleRuleset object and won't be altered by this measure.")
        os_sch.remove # remove un-used clone
      end
    end


    ######################################################################
    optional_heating_period_inputs = { "period2" => {"date_start"=>os_heating_start_date2, "date_end"=>os_heating_end_date2,
                                                     "time_start"=>heating_shift_time_start2, "time_end"=>heating_shift_time_end2},
                                       "period3" => {"date_start"=>os_heating_start_date3, "date_end"=>os_heating_end_date3,
                                                     "time_start"=>heating_shift_time_start3, "time_end"=>heating_shift_time_end3},
                                       "period4" => {"date_start"=>os_heating_start_date4, "date_end"=>os_heating_end_date4,
                                                     "time_start"=>heating_shift_time_start4, "time_end"=>heating_shift_time_end4},
                                       "period5" => {"date_start"=>os_heating_start_date5, "date_end"=>os_heating_end_date5,
                                                     "time_start"=>heating_shift_time_start5, "time_end"=>heating_shift_time_end5} }
    # make heating schedule adjustments and rename. Put in check to skip and warn if schedule not ruleset
    htg_set_schs.each do |old_sch_name, os_sch| # old name and new object for schedule
      if !os_sch.to_ScheduleRuleset.empty?
        schedule = os_sch.to_ScheduleRuleset.get
        rules = schedule.scheduleRules
        days_covered = Array.new(7, false)
        if rules.length <= 0
          runner.registerWarning("Heating setpoint schedule '#{old_sch_name}' is a ScheduleRuleSet, but has no ScheduleRules associated. It won't be altered by this measure.")
        else
          current_index = 0
          rules.each do |rule|
            rule_period1 = modify_rule_for_date_period(rule, os_heating_start_date1, os_heating_end_date1,
                                                       heating_shift_time_start1, heating_shift_time_end1,
                                                       heating_adjustment_ip, model)
            if rule_period1
              applicable_flag = true
              checkDaysCovered(rule_period1, days_covered)
              runner.registerInfo("--------------- current days of week coverage: #{days_covered}")
              if schedule.setScheduleRuleIndex(rule_period1, current_index)
                current_index += 1
              else
                runner.registerError("Fail to set rule index for #{rule_period1.name.to_s}.")
              end
            end
            final_htg_sch_set_values << rule_period1.daySchedule.values

            optional_heating_period_inputs.each do |period, period_inputs|
              os_start_date = period_inputs["date_start"]
              os_end_date = period_inputs["date_end"]
              shift_time_start = period_inputs["time_start"]
              shift_time_end = period_inputs["time_end"]
              if [os_start_date, os_end_date, shift_time_start, shift_time_end].all?
                rule_period = modify_rule_for_date_period(rule, os_start_date, os_end_date, shift_time_start, shift_time_end,
                                                          heating_adjustment_ip, model)
                if rule_period
                  applicable_flag = true
                  if schedule.setScheduleRuleIndex(rule_period, current_index)
                    current_index += 1
                  else
                    runner.registerError("Fail to set rule index for #{rule_period.name.to_s}.")
                  end
                end
                runner.registerInfo("------------ heating schedule #{old_sch_name} updated for #{rule_period.startDate.get} to #{rule_period.endDate.get}")
              end
            end
            # The original rule will be shifted to the currently lowest priority
            # Setting the rule to an existing index will automatically push all other rules after it down
            if schedule.setScheduleRuleIndex(rule, current_index)
              current_index += 1
            else
              runner.registerError("Fail to set rule index for #{rule.name.to_s}.")
            end
          end
        end

        default_day = schedule.defaultDaySchedule
        if days_covered.include?(false)
          runner.registerInfo("Some days use default day. Adding new scheduleRule from defaultDaySchedule for applicable date period.")
          modify_default_day_for_date_period(schedule, default_day, days_covered, os_heating_start_date1, os_heating_end_date1,
                                             heating_shift_time_start1, heating_shift_time_end1, heating_adjustment_ip)
          optional_heating_period_inputs.each do |period, period_inputs|
            os_start_date = period_inputs["date_start"]
            os_end_date = period_inputs["date_end"]
            shift_time_start = period_inputs["time_start"]
            shift_time_end = period_inputs["time_end"]
            if [os_start_date, os_end_date, shift_time_start, shift_time_end].all?
              modify_default_day_for_date_period(schedule, default_day, days_covered, os_start_date, os_end_date,
                                                 shift_time_start, shift_time_end, heating_adjustment_ip)
              applicable_flag = true
            end
          end
          final_htg_sch_set_values << default_day.values
        end

      else
        runner.registerWarning("Schedule '#{old_sch_name}' isn't a ScheduleRuleset object and won't be altered by this measure.")
        os_sch.remove # remove un-used clone
      end
    end


    # not applicable if no schedules can be altered
    if applicable_flag == false
      runner.registerAsNotApplicable('No thermostat schedules in the models could be altered.')
    end

    # get min and max heating and cooling and convert to IP for final
    final_clg_sch_set_values = final_clg_sch_set_values.flatten
    final_htg_sch_set_values = final_htg_sch_set_values.flatten


    if !final_clg_sch_set_values.empty?
      final_min_clg_si = OpenStudio::Quantity.new(final_clg_sch_set_values.min, TEMP_SI_UNIT)
      final_max_clg_si = OpenStudio::Quantity.new(final_clg_sch_set_values.max, TEMP_SI_UNIT)
      final_min_clg_ip = OpenStudio.convert(final_min_clg_si, TEMP_IP_UNIT).get
      final_max_clg_ip = OpenStudio.convert(final_max_clg_si, TEMP_IP_UNIT).get
    else
      final_min_clg_ip = 'NA'
      final_max_clg_ip = 'NA'
    end

    # get min and max if values exist
    if !final_htg_sch_set_values.empty?
      final_min_htg_si = OpenStudio::Quantity.new(final_htg_sch_set_values.min, TEMP_SI_UNIT)
      final_max_htg_si = OpenStudio::Quantity.new(final_htg_sch_set_values.max, TEMP_SI_UNIT)
      final_min_htg_ip = OpenStudio.convert(final_min_htg_si, TEMP_IP_UNIT).get
      final_max_htg_ip = OpenStudio.convert(final_max_htg_si, TEMP_IP_UNIT).get
    else
      final_min_htg_ip = 'NA'
      final_max_htg_ip = 'NA'
    end

    # reporting final condition of model
    finishing_spaces = model.getSpaces
    runner.registerFinalCondition("Final cooling setpoints used in the model range from #{final_min_clg_ip} to #{final_max_clg_ip}. Final heating setpoints used in the model range from #{final_min_htg_ip} to #{final_max_htg_ip}.")

    return true
  end



  def modify_rule_for_date_period(original_rule, os_start_date, os_end_date, shift_time_start, shift_time_end, lpd_factor, model)
    # The cloned scheduleRule will automatically belongs to the originally scheduleRuleSet
    rule_period = original_rule.clone(model).to_ScheduleRule.get
    rule_period.setName("#{original_rule.name.to_s} with DF for #{os_start_date.to_s}-#{os_end_date.to_s}")
    rule_period.setStartDate(os_start_date)
    rule_period.setEndDate(os_end_date)
    day_rule_period = rule_period.daySchedule
    day_time_vector = day_rule_period.times
    day_value_vector = day_rule_period.values
    if day_time_vector.empty?
      return false
    end
    day_rule_period.clearValues
    day_rule_period = updateDaySchedule(day_rule_period, day_time_vector, day_value_vector, shift_time_start, shift_time_end, lpd_factor)
    return rule_period
  end

  def modify_default_day_for_date_period(schedule_set, default_day, days_covered, os_start_date, os_end_date,
                                         shift_time_start, shift_time_end, lpd_factor)
    # the new rule created for the ScheduleRuleSet by default has the highest priority (ruleIndex=0)
    new_default_rule = OpenStudio::Model::ScheduleRule.new(schedule_set, default_day)
    new_default_rule.setName("#{schedule_set.name.to_s} default day with DF for #{os_start_date.to_s}-#{os_end_date.to_s}")
    new_default_rule.setStartDate(os_start_date)
    new_default_rule.setEndDate(os_end_date)
    coverMissingDays(new_default_rule, days_covered)
    new_default_day = new_default_rule.daySchedule
    day_time_vector = new_default_day.times
    day_value_vector = new_default_day.values
    new_default_day.clearValues
    new_default_day = updateDaySchedule(new_default_day, day_time_vector, day_value_vector, shift_time_start, shift_time_end, lpd_factor)
    schedule_set.setScheduleRuleIndex(new_default_rule, 0)
    # TODO: if the scheduleRuleSet has holidaySchedule (which is a ScheduleDay), it cannot be altered
  end



  def checkDaysCovered(sch_rule, sch_day_covered)
    if sch_rule.applySunday
      sch_day_covered[0] = true
    end
    if sch_rule.applyMonday
      sch_day_covered[1] = true
    end
    if sch_rule.applyTuesday
      sch_day_covered[2] = true
    end
    if sch_rule.applyWednesday
      sch_day_covered[3] = true
    end
    if sch_rule.applyThursday
      sch_day_covered[4] = true
    end
    if sch_rule.applyFriday
      sch_day_covered[5] = true
    end
    if sch_rule.applySaturday
      sch_day_covered[6] = true
    end
  end

  def coverMissingDays(sch_rule, sch_day_covered)
    if sch_day_covered[0] == false
      sch_rule.setApplySunday(true)
    end
    if sch_day_covered[1] == false
      sch_rule.setApplyMonday(true)
    end
    if sch_day_covered[2] == false
      sch_rule.setApplyTuesday(true)
    end
    if sch_day_covered[3] == false
      sch_rule.setApplyWednesday(true)
    end
    if sch_day_covered[4] == false
      sch_rule.setApplyThursday(true)
    end
    if sch_day_covered[5] == false
      sch_rule.setApplyFriday(true)
    end
    if sch_day_covered[6] == false
      sch_rule.setApplySaturday(true)
    end

  end


  # TODO check if this function works
  def updateDaySchedule(sch_day, vec_time, vec_value, time_begin, time_end, adjustment)
    # indicator: 0:schedule unchanged, 1:schedule changed at least once, 2:schedule change completed
    count = 0
    for i in 0..(vec_time.size - 1)
      v_si = OpenStudio::Quantity.new(vec_value[i], TEMP_SI_UNIT)
      v_ip = OpenStudio.convert(v_si, TEMP_IP_UNIT).get
      target_v_ip = v_ip + adjustment
      target_temp_si = OpenStudio.convert(target_v_ip, TEMP_SI_UNIT).get
      if vec_time[i]>time_begin&&vec_time[i]<time_end && count == 0
        sch_day.addValue(time_begin, vec_value[i])
        sch_day.addValue(vec_time[i],target_temp_si.value)
        count = 1
      elsif vec_time[i]>time_end && count == 0
        sch_day.addValue(time_begin,vec_value[i])
        sch_day.addValue(time_end,target_temp_si.value)
        sch_day.addValue(vec_time[i],vec_value[i])
        count = 2
      elsif vec_time[i]>time_begin && vec_time[i]<=time_end && count==1
        sch_day.addValue(vec_time[i], vec_value[i])
      elsif vec_time[i]>time_end && count == 1
        sch_day.addValue(time_end, target_temp_si.value)
        sch_day.addValue(vec_time[i], vec_value[i])
        count = 2
      else
        # override
        target_v_ip = v_ip
        target_temp_si = OpenStudio.convert(target_v_ip, TEMP_SI_UNIT).get
        sch_day.addValue(vec_time[i], target_temp_si.value)
      end
    end
    return sch_day
  end

end



# this allows the measure to be used by the application
AdjustThermostatSetpointsByDegreesForPeakHours.new.registerWithApplication
