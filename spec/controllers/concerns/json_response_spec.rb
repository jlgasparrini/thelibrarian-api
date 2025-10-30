require 'rails_helper'

RSpec.describe JsonResponse, type: :controller do
  controller(ApplicationController) do
    include JsonResponse

    def index
      case params[:action_type]
      when 'paginated'
        collection = Book.all
        pagy = Pagy.new(count: collection.count, page: 1, limit: 10)
        render_paginated_collection(collection, pagy, serializer: params[:serializer], key: params[:key])
      when 'resource'
        render_resource({ id: 1, title: 'Test Book' }, key: :book, extra: 'data')
      when 'success'
        render_success('Operation successful', extra: 'info')
      when 'created'
        render_created({ id: 1, title: 'New Book' }, key: :book, message: 'Book created successfully')
      when 'errors'
        render_errors([ 'Error 1', 'Error 2' ], status: :bad_request)
      when 'not_found'
        if params[:message].present?
          render_not_found(params[:message])
        else
          render_not_found
        end
      when 'unauthorized'
        if params[:message].present?
          render_unauthorized(params[:message])
        else
          render_unauthorized
        end
      end
    end
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
  end

  describe '#render_paginated_collection' do
    let!(:book1) { create(:book, title: 'Book 1') }
    let!(:book2) { create(:book, title: 'Book 2') }

    context 'without serializer' do
      it 'renders paginated collection with default key' do
        get :index, params: { action_type: 'paginated' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('books')
        expect(json).to have_key('pagination')
        expect(json['pagination']).to include('current_page', 'per_page', 'total_count', 'total_pages')
      end
    end

    # Custom serializer testing is covered by integration tests
    # (e.g., spec/requests/api/v1/books_spec.rb, borrowings_spec.rb)
    # where we verify the actual serialized output

    context 'with custom key' do
      it 'uses the provided key' do
        get :index, params: { action_type: 'paginated', key: 'custom_books' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('custom_books')
      end
    end
  end

  describe '#render_resource' do
    it 'renders a single resource with key' do
      get :index, params: { action_type: 'resource' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('book')
      expect(json).to have_key('extra')
      expect(json['book']).to include('id' => 1, 'title' => 'Test Book')
      expect(json['extra']).to eq('data')
    end
  end

  describe '#render_success' do
    it 'renders success message with additional options' do
      get :index, params: { action_type: 'success' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('message')
      expect(json).to have_key('extra')
      expect(json['message']).to eq('Operation successful')
      expect(json['extra']).to eq('info')
    end
  end

  describe '#render_created' do
    it 'renders created resource with message and 201 status' do
      get :index, params: { action_type: 'created' }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json).to have_key('book')
      expect(json).to have_key('message')
      expect(json['book']).to include('id' => 1, 'title' => 'New Book')
      expect(json['message']).to eq('Book created successfully')
    end
  end

  describe '#render_errors' do
    it 'renders errors with custom status' do
      get :index, params: { action_type: 'errors' }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json).to have_key('errors')
      expect(json['errors']).to eq([ 'Error 1', 'Error 2' ])
    end
  end

  describe '#render_not_found' do
    context 'with default message' do
      it 'renders not found with default message' do
        get :index, params: { action_type: 'not_found' }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json).to have_key('error')
        expect(json['error']).to eq('Record not found')
      end
    end

    context 'with custom message' do
      it 'renders not found with custom message' do
        get :index, params: { action_type: 'not_found', message: 'Book not found' }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Book not found')
      end
    end
  end

  describe '#render_unauthorized' do
    context 'with default message' do
      it 'renders unauthorized with default message' do
        get :index, params: { action_type: 'unauthorized' }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json).to have_key('error')
        expect(json['error']).to eq('You are not authorized to perform this action')
      end
    end

    context 'with custom message' do
      it 'renders unauthorized with custom message' do
        get :index, params: { action_type: 'unauthorized', message: 'Access denied' }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Access denied')
      end
    end
  end
end
