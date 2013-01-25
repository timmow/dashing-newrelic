require 'bundler/setup'
require 'new_relic_api'

SCHEDULER.every '1h' do
  NewRelicApi.api_key = 'INSERT_API_KEY_HERE'
  account = NewRelicApi::Account.application_health
  red_apps = account.applications.find_all do |app|
    app.threshold_values.find { |thresh| thresh.name == 'Apdex' and thresh.color_value == 'Red' }
  end
  values = red_apps.map do |app|
    threshold = app.threshold_values.find { |thresh| thresh.name == 'Apdex' and thresh.color_value == 'Red' }
    {label: app.name, value: threshold.metric_value}
  end
  
  send_event('newrelic', { items: values })
end
