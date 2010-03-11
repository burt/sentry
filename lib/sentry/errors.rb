module Sentry
  class SentryNotDefined < StandardError; end
  class InvalidSentry < StandardError; end
  class NotAuthorized < StandardError; end
  class ModelNotFound < StandardError; end
  class SubjectNotFound < StandardError; end
end