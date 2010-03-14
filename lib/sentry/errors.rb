module Sentry
  class SentryNotFound < StandardError; end
  class InvalidSentry < StandardError; end
  class NotAuthorized < StandardError; end
  class ModelNotFound < StandardError; end
  class SubjectNotFound < StandardError; end
end