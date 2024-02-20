(** The type of input bit streams *)
type istream

(** Raised by read and write functions in case of error *)
exception Invalid_stream

(** Raise by read_* functions to signal the end of a stream *)
exception End_of_stream

(** [of_in_channel ic] creates an istream from an already opened in_channel. The
    [read_*] functions consume the channel. The behaviour is unspecified if the
    channel is modified using other functions from the standard library. May
    raise [Invalid_stream] if the underlying stream is not correctly formatted. *)
val of_in_channel : in_channel -> istream

(** [read_bit is] reads the next bit in the stream (returned as the integer 0 or
    1). May raise [End_of_stream] if the last bit as already been read. May
    raise [Invalid_stream] if the underlying stream is not correctly formatted. *)
val read_bit : istream -> int

(** [read_n_bits is n] returns the next [n] bits of [is] packed in an integer.
    May raise [End_of_stream] if there are less than [n] bits remaining. May
    raise [Invalid_stream] if the underlying stream is not correctly formatted.
    May raise [Invalid_argument msg] with an appropriate message [msg] if [n] is
    negative or larger than [Sys.int_size]. *)
val read_n_bits : istream -> int -> int

(** [read_byte is] is an alias for [read_n_bits is 8]. *)
val read_byte : istream -> int

(** [read_short is] is an alias for [read_n_bits is 16]. *)
val read_short : istream -> int

(** [read_byte is] is an alias for [read_n_bits is Sys.int_size]. *)
val read_int : istream -> int

(** The type of output bit streams *)
type ostream

(** [of_out_channel :oc] creates on ostream from an already opened
    [out_channel]. The [write_*] function writes to the channel, increasing the
    internal position cursor. The behaviour is unspecified if the [oc] is
    manipulated with other functions. *)
val of_out_channel : out_channel -> ostream

(** [write_bit os b] writes the least significant bit of [b] to the stream. May
    raise [Invalid_stream] if [os] has already been finalized. *)
val write_bit : ostream -> int -> unit

(** [write_n_bits os n b] write the lowermost [n] bits of [b] from least
    significant to most significant. May raise [Invalid_argument msg] with an
    appropriate message [msg] if [n] is negative or larger than [Sys.int_size]. *)
val write_n_bits : ostream -> int -> int -> unit

(** [write_byte os b] is an alias for [write_n_bits os 8 b] *)
val write_byte : ostream -> int -> unit

(** [write_short os b] is an alias for [write_n_bits os 16 b] *)
val write_short : ostream -> int -> unit

(** [write_int os b] is an alias for [write_n_bits os Sys.int_size b] *)
val write_int : ostream -> int -> unit

(** [finalise os] must be called after the last bit has been written to [os].
    Since out_channels are byte-adressed, one cannot write to a channel a number
    of bytes that is not a multiple of 8. If therefore the last [0<= n <= 7]
    bits of [os] are written has a whole byte (with some garbage bits) and [n]
    is written as the last byte of the out_channel.

    Closing the underlying channel without calling [finalize] first will most
    likely yield an invalid [istream] when read back with [of_in_channel]. *)
val finalize : ostream -> unit
