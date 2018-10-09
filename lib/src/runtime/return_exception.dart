// Special exception for unwinding the stack in the 
// interpreter with a return value.
class Return implements Exception {
  final Object value;

  Return(this.value);
}