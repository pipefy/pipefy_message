# frozen_string_literal: true

module PipefyMessage
  module Providers
    ##
    # Provides a provider-agnostic, higher level abstraction for
    # provider clients and resources. Should be included in classes
    # implemented for specific providers. Used by the Worker module.
    class Broker
      include PipefyMessage::Logging
      include PipefyMessage::Providers::Errors

      # def poller
      #   error_msg = includer_should_implement(__method__)
      #   raise NotImplementedError, error_msg
      # end

      # def publish(_payload, _topic_name)
      #   error_msg = includer_should_implement(__method__)
      #   raise NotImplementedError, error_msg
      # end

      # I actually believe these "abstract methods" shouldn't
      # exist at this level, since they are only implemented by
      # the "grandchildren" of this class, rather than its children.
      # Unless the idea is to allow calling the grandchildren classes
      # connected to each service from the child class itself (the one)
      # connected to the provider -- eg: fire up SQS polling by calling
      # aws_broker.poller directly, rather than instantiating an SQS-
      # specific class. Thoughts? Comments?

      def default_options
        error_msg = includer_should_implement(__method__)
        raise NotImplementedError, error_msg
      end

      # At the current point, as we're working solely with AWS, it's
      # hard to know what this abstract class should or shouldn't have
      # -- at least for me, since I don't know how this would work for
      # other providers' SDKs. This class is mostly empty at the moment,
      # but shared functionality should be abstracted away into it as
      # other providers are introduced.
    end
  end
end
