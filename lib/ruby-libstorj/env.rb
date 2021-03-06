module LibStorj
  class Env
    require 'libuv'
    require 'json'
    attr_reader :storj_env

    C_ANALOGUE = ::LibStorj::Ext::Storj::Env

    def initialize(*options)
      @storj_env = ::LibStorj::Ext::Storj.method(:init_env).call(*options)
      @storj_env[:loop] = ::Libuv::Ext.default_loop
    end

    def destroy
      ::LibStorj::Ext::Storj.destroy_env @storj_env
    end

    def get_info(&block)
      ruby_handle = ::LibStorj::Ext::Storj::JsonRequest.ruby_handle(&block)
      after_work_cb = ::LibStorj::Ext::Storj::JsonRequest.after_work_cb

      uv_queue_and_run do
        ::LibStorj::Ext::Storj.get_info @storj_env,
                                        ruby_handle,
                                        after_work_cb
      end
    end

    def delete_bucket(bucket_id, &block)
      after_work_cb = ::LibStorj::Ext::Storj::JsonRequest.after_work_cb
      ruby_handle = ::LibStorj::Ext::Storj::JsonRequest.ruby_handle do |error|
        yield error if block
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::Bucket.delete @storj_env,
                                              bucket_id,
                                              ruby_handle,
                                              after_work_cb
      end
    end

    def get_buckets(&block)
      after_work_cb = ::LibStorj::Ext::Storj::GetBucketRequest.after_work_cb
      ruby_handle = ::LibStorj::Ext::Storj::GetBucketRequest.ruby_handle(&block)

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::Bucket.all @storj_env,
                                           ruby_handle,
                                           after_work_cb
      end
    end

    def create_bucket(name, &block)
      req_data_type = ::LibStorj::Ext::Storj::CreateBucketRequest
      after_work_cb = req_data_type.after_work_cb
      ruby_handle = req_data_type.ruby_handle(&block)

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::Bucket.create @storj_env,
                                              name,
                                              ruby_handle,
                                              after_work_cb
      end
    end

    def list_files(bucket_id, &block)
      req_data_type = ::LibStorj::Ext::Storj::ListFilesRequest
      after_work_cb = req_data_type.after_work_cb
      ruby_handle = req_data_type.ruby_handle(&block)

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::File.all @storj_env,
                                          bucket_id,
                                          ruby_handle,
                                          after_work_cb
      end
    end

    def uv_queue_and_run
      reactor do |reactor|
        @chain = reactor.work do
          yield
        end.catch do |error|
          raise error
        end
      end
      @chain
    end

    private :uv_queue_and_run
  end
end
