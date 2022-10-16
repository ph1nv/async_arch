KAFKA_PRODUCER = WaterDrop::Producer.new

KAFKA_PRODUCER.setup do |config|
  config.kafka = { 'bootstrap.servers': 'localhost:29092' }
end
