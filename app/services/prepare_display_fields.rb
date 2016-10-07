class PrepareDisplayFields
  def initialize(client_data_instance)
    @obj = { data: client_data_instance }
    @obj[:special_keys] = load_special_keys
  end

  def run
    process_fields
  end

  def process_fields
    client_display = {}

    @obj[:data].attributes.each do |key, value|
      @obj[:key] = key
      @obj[:value] = value
      client_display[key] = modify_display
    end
    client_display["total_price"] = add_total_price
    client_display
  end

  def add_total_price
    sprintf("%.2f", Object.const_get(@obj[:data].class.name).find(@obj[:data].id).total_price)
  end

  def load_special_keys
    Object.const_get(@obj[:data].class.name).special_keys
  end

  def modify_display
    data = @obj[:data]
    key = @obj[:key]
    value = @obj[:value]
    if @obj[:special_keys].include? key
      Object.const_get(data.class.name).send("display_update_" + key, @obj)
    elsif value.nil? || value.blank?
      "--"
    else
      value
    end
  end

  private

  attr_accessor :client_data_instance
end
