enum TypeStatus{ create, modify, copy }

mixin CreateEntityUtils {

  TypeStatus _type = TypeStatus.create;

  bool isNew() => this._type == TypeStatus.create;

  bool isCopy() => this._type == TypeStatus.copy;

  bool isModify() => this._type == TypeStatus.modify;

  void setType(TypeStatus type) => this._type = type;

}