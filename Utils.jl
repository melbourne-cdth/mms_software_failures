using Markdown

"""
From [https://discourse.julialang.org/](https://discourse.julialang.org/t/how-do-i-convert-a-binary-string-to-a-floating-point-number/21380/3)
"""
function float_from_bitstring(::Type{T}, str::String) where {T<:Base.IEEEFloat}
    unsignedbits = Meta.parse(string("0b", str))
    thefloat  = reinterpret(T, unsignedbits)
    return thefloat
end

function mask_float_bitstring(x, n::Int)
	t = bitstring(x)
	i = endexp(x)
	nt = t[1:i+n]*repeat("0",(length(t)-(i+n)))
	reinterpret(typeof(x), Meta.parse(string("0b", nt)))
end


endexp(x) = exponent_length(typeof(x))+1


signbit(x::AbstractFloat)=bitstring(x)[1:1];

exponent_length(T::Type{<:AbstractFloat})=Int(log2(exponent(floatmax(T))+1)+1);

significand_length(T::Type{<:AbstractFloat})=8*sizeof(T)-exponent_length(T)-1+1;

exponent_bits(x::AbstractFloat)=bitstring(x)[2:exponent_length(typeof(x))+1]

significand_bits(x::AbstractFloat)=bitstring(x)[exponent_length(typeof(x))+2:8*sizeof(x)];

floatbits(x::AbstractFloat)=signbit(x)*"_"*exponent_bits(x)*"_"*significand_bits(x);

function typesof(x...)
    join(map(y->"type of $(y) is $(typeof(y))", x), "\n")
end

overflows =  HTML("""<details><summary><strong><h3>9223372036854775807+1 in other languages</h3></strong></summary>
<table>
  <tr>
    <th>Language</th>
    <th>Result</th>
  </tr>
  <tr>
    <td>Python</td>
    <td>9223372036854775808</td>
  </tr>
  <tr>
    <td>Go</td>
    <td>untyped constant {int 9223372036854775808} overflows <int></td>
  </tr>
  <tr>
    <td>R</td>
    <td>9223372036854775808</td>
  </tr>
  <tr>
    <td>Rust</td>
    <td>9223372036854775807i64 + 1 attempt to compute `i64::MAX + 1_i64` which would overflow
this arithmetic operation will overflow</td>
  </tr>
</table>
<h2>Why would you ever let a language do what Julia does or Go/Rust does rather than what Python and R do?
</h2>
</details>""");
