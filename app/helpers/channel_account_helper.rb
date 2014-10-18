module ChannelAccountHelper
  def select(result_range, select_range)
    result = 0
    ( select_range[rand(select_range.length)] ).times { result += result_range[rand(result_range.length)] }
    result
  end
  
  REST_RANGE = [1, 1, 1, 1, 2]
  REST_MAX_SELECT_RANGE = [1, 1, 1, 1, 2]
  BLOOD_MACHINE_RANGE = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 10]
  BLOOD_MACHINE_SELECT_RANGE = [1, 1, 1, 1, 1, 1, 1, 1, 1, 2]
  
  def select_blood_machine
    select(REST_RANGE, REST_MAX_SELECT_RANGE)
  end
  
  def select_rest
    select(BLOOD_MACHINE_RANGE, BLOOD_MACHINE_SELECT_RANGE)
  end
  
  STATUS_RESTING = "resting"
  STATUS_DONATING_BLOOD = "donating_blood"
  STATUS_BETTING = "betting"
  STATUS_INACTIVE = "inactive"
  
  VALID_STATUSES = [STATUS_RESTING, STATUS_DONATING_BLOOD, STATUS_BETTING, STATUS_INACTIVE]
end