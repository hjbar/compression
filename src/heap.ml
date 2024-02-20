type 'a heap =
  { size : int
  ; tas : 'a array
  }

let empty t = { size = 0; tas = Array.init 0 (fun _i -> t) }

let heap_size h = h.size

let heap_tas h = h.tas

let is_singleton h = h.size = 1

let is_empty h = h.size = 0

let add elem h f =
  let rec monte h ind =
    if ind > 0 && f h.tas.((ind - 1) / 2) elem then begin
      h.tas.(ind) <- h.tas.((ind - 1) / 2);
      monte h ((ind - 1) / 2)
    end
    else h.tas.(ind) <- elem
  in
  let size = h.size + 1 in
  let tas =
    if heap_size h = 0 then Array.init 1 (fun _i -> elem)
    else if h.size + 1 >= Array.length h.tas then
      Array.append h.tas (Array.init (Array.length h.tas) (fun _i -> elem))
    else h.tas
  in
  let h = { size; tas } in
  monte h (h.size - 1);
  h

let find_min h = h.tas.(0)

let remove_min h f =
  let rec loop h elem ind =
    h.tas.(ind) <- elem;
    if (2 * ind) + 2 < h.size then begin
      let min_fils =
        f (heap_tas h).((2 * ind) + 2) (heap_tas h).((2 * ind) + 1)
      in
      let min_pere_fils_g = f elem (heap_tas h).((2 * ind) + 1) in
      let min_pere_fils_r = f elem (heap_tas h).((2 * ind) + 2) in

      if min_fils && min_pere_fils_g then begin
        h.tas.(ind) <- h.tas.((2 * ind) + 1);
        loop h elem ((2 * ind) + 1)
      end
      else if (not min_fils) && min_pere_fils_r then begin
        h.tas.(ind) <- h.tas.((2 * ind) + 2);
        loop h elem ((2 * ind) + 2)
      end
    end
    else if (2 * ind) + 1 < h.size then begin
      let min_pere_fils_g = f elem (heap_tas h).((2 * ind) + 1) in
      if min_pere_fils_g then begin
        h.tas.(ind) <- h.tas.((2 * ind) + 1);
        loop h elem ((2 * ind) + 1)
      end
    end
  in
  h.tas.(0) <- h.tas.(h.size - 1);
  let size = h.size - 1 in
  let tas =
    if h.size - 1 > Array.length h.tas / 4 then h.tas
    else Array.sub h.tas 0 (Array.length h.tas / 2)
  in
  let h = { size; tas } in
  loop h h.tas.(0) 0;
  h
