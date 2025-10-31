Sidekiq.configure_server do |config|
  config.redis = { url: "redis://redis:6379/0" }
  if defined?(Sidekiq::Cron)
    schedule = YAML.load_file(Rails.root.join("config", "sidekiq_schedule.yml"))
    Sidekiq::Cron::Job.load_from_hash(schedule)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://redis:6379/0" }
end