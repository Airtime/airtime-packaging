  aac_mimes = ["audio/aac", "audio/aacp", "audio/3gpp", "audio/3gpp2", "audio/mp4",
               "audio/MP4A-LATM", "audio/mpeg4-generic", "audio/x-hx-aac-adts"]
  aac_filexts = ["m4a", "m4b", "m4p", "m4v",
                 "m4r", "3gp", "mp4", "aac"]

  # Faad is not very selective so
  # We are checking only file that
  # end with a known extension or mime type
  def faad_test(file) =
    # Get the file's mime
    mime = get_mime(file)
    # Test mime
    if list.mem(mime,aac_mimes) then
      true
    else
      # Otherwise test file extension
      ret = string.extract(pattern='\.(.+)$',file)
        if list.length(ret) != 0 then
          ext = ret["1"]
          list.mem(ext,aac_filexts)
        else
          false
        end
    end
  end

  if test_process("which faad") then
    log(level=3,"Found faad binary: enabling external faad decoder and \
                 metadata resolver.")
    faad_p = (fun (f) -> "faad -w #{quote(f)} 2>/dev/null")
    def test_faad(file) =
      if faad_test(file) then
        channels = list.hd(get_process_lines("faad -i #{quote(file)} 2>&1 | \
                                              grep 'ch,'"))
        ret = string.extract(pattern=", (\d) ch,",channels)
        ret =
          if list.length(ret) == 0 then
          # If we pass the faad_test, chances are
          # high that the file will contain aac audio data..
            "-1"
          else
            ret["1"]
          end
        int_of_string(default=(-1),ret)
      else
        0
      end
    end
    add_oblivious_decoder(name="FAAD",description="Decode files using \
                          the faad binary.", test=test_faad, faad_p)
    def faad_meta(file) =
      if faad_test(file) then
        ret = get_process_lines("faad -i \
                     #{quote(file)} 2>&1")
        # Yea, this is tuff programming (again) !
        def get_meta(l,s)=
          ret = string.extract(pattern="^(\w+):\s(.+)$",s)
          if list.length(ret) > 0 then
            list.append([(ret["1"],ret["2"])],l)
          else
            l
          end
        end
        list.fold(get_meta,[],ret)
      else
        []
      end
    end
    add_metadata_resolver("FAAD",faad_meta)
  end
