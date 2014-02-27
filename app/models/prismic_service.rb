module PrismicService
  class << self

    # Easier reading in the prismic.yml configuration file.
    def config(key=nil)
      @config ||= YAML.load_file(Rails.root + "config" + "prismic.yml")
      key ? @config.fetch(key) : @config
    end

    # The access token in configuration.
    def access_token
      config['token']
    end

    ## Easier initialisation of the Prismic::API object.
    def init_api(access_token)
      access_token ||= self.access_token
      Prismic.api(config('url'), access_token)
    end

    # Gets a document from its ID.
    def get_document(id, api, ref)
      documents = api.form("everything")
                     .query("[[:d = at(document.id, \"#{id}\")]]")
                     .submit(ref)

      documents.empty? ? nil : documents.first
    end

    # Checks if the slug is the right one for the document.
    # You can change this depending on your URL strategy.
    def slug_checker(document, slug)
      if document.nil?
        return { correct: false, redirect: false }
      elsif slug == document.slug
        return { correct: true }
      elsif document.slugs.include?(slug)
        return { correct: false, redirect: true }
      else
        return { correct: false, redirect: false }
      end
    end


    @@expected_ref = nil
    @@expected_ID_list = nil

    # Allows to pass a block of things to do when new documents have just been published.
    # You may pass predicates to query on, so that the block is executed only when a subset of documents sees a newcomer.
    def on_new_document(api, predicates= '')
      ref = api.master.ref # Current master ref
      if !@@expected_ref # First ever time we check: initializing
        @@expected_ref = ref
        @@expected_ID_list = api.form('everything').query(predicates).set('pageSize', '100000000').submit(ref).map { |document| document.id }
      elsif @@expected_ref != ref # The ref has changed
        # all documents whose IDs are not listed as existing
        new_documents = api.form('everything').query(predicates).set('pageSize', '100000000').submit(ref).select {|document| !@@expected_ID_list.include?(document.id) }
        # yielding this list of new documents
        yield(new_documents)
        # updating what's expected for next time
        @@expected_ID_list = new_documents.map{|doc| doc.id}
        @@expected_ref = ref
      end
    end

  end
end
