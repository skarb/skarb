#ifndef TYPES_H_
#define TYPES_H_

/**
 * Numeric identifiers of standard types.
 */
enum {
  Object_t = 0,
  Fixnum_t,
  Float_t,
  String_t,
  NilClass_t,
  Array_t,
  Hash_t,
  /**
   * The following identifier is the first value which can be used for
   * user-defined types.
   */
  FIRST_USER_TYPE
};

#endif /* TYPES_H_ */
