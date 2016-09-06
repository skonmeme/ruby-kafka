require "zlib"

module Kafka

  # Assigns partitions to messages.
  class Partitioner

    # Assigns a partition number based on a partition key. If no explicit
    # partition key is provided, the message key will be used instead.
    #
    # If the key is nil, then a random partition is selected. Otherwise, a digest
    # of the key is used to deterministically find a partition. As long as the
    # number of partitions doesn't change, the same key will always be assigned
    # to the same partition.
    #
    # @param partition_count [Integer] the number of partitions in the topic.
    # @param message [Kafka::PendingMessage] the message that should be assigned
    #   a partition.
    # @return [Integer] the partition number.
    def self.partition_for_message(partition_count, message)
      # If no explicit partition key is specified we use the message key instead.
      partition_for_key(partition_count, message.partition_key || message.key)
    end

    def self.partition_for_key(partition_count, key)
      raise ArgumentError if partition_count == 0

      if key.nil?
        rand(partition_count)
      else
        Zlib.crc32(key) % partition_count
      end
    end
  end
end
