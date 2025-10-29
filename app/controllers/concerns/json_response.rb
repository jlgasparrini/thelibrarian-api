module JsonResponse
  extend ActiveSupport::Concern

  # Render paginated collection with metadata
  def render_paginated_collection(collection, pagy, serializer: nil, key: nil, **options)
    serialized_data = if serializer
      collection.map { |item| serializer.call(item) }
    else
      collection
    end

    response_key = key || collection.model_name.plural

    render json: {
      response_key => serialized_data,
      pagination: pagy_metadata(pagy)
    }.merge(options), status: :ok
  end

  # Render single resource
  def render_resource(resource, key:, **options)
    render json: {
      key => resource
    }.merge(options), status: :ok
  end

  # Render success message
  def render_success(message, **options)
    render json: {
      message: message
    }.merge(options), status: :ok
  end

  # Render created resource
  def render_created(resource, key:, message:, **options)
    render json: {
      key => resource,
      message: message
    }.merge(options), status: :created
  end

  # Render errors
  def render_errors(errors, status: :unprocessable_content)
    render json: {
      errors: errors
    }, status: status
  end

  # Render not found
  def render_not_found(message = "Record not found")
    render json: {
      error: message
    }, status: :not_found
  end

  # Render unauthorized
  def render_unauthorized(message = "You are not authorized to perform this action")
    render json: {
      error: message
    }, status: :forbidden
  end
end
