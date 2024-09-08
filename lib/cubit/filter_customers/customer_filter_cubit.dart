import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:venturiautospurghi/models/filter_wrapper.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';

part 'customer_filter_state.dart';

class CustomerFilterCubit extends Cubit<CustomersFilterState> {
  final CloudFirestoreService _databaseRepository;
  final Function callbackFiltersChanged;
  final Function callbackSearchFieldChanged;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController addressController;
  late TextEditingController paritaivaController;
  late TextEditingController codicefiscaleController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  CustomerFilterCubit(this._databaseRepository, this.callbackSearchFieldChanged, this.callbackFiltersChanged) : super(CustomersFilterState()) {
    titleController = new TextEditingController();
    addressController = new TextEditingController();
    phoneController = new TextEditingController();
    emailController = new TextEditingController();
    paritaivaController = new TextEditingController();
    codicefiscaleController = new TextEditingController();
    initFilters();
  }

  void initFilters(){
    titleController.text = '';
    addressController.text= '';
    phoneController.text= '';
    Map<String, FilterWrapper> filters = Map.from(CustomersFilterState().filters);
    emit(state.assign(filters: filters));
  }

  void showFiltersBox() {
    emit(state.assign(filtersBoxVisibile:!state.filtersBoxVisibile));
  }

  void onSearchFieldTextChanged(String text){
    state.filters["name-surname"]!.fieldValue = text;
    callbackSearchFieldChanged(state.filters);
  }

  setIsCompany(bool? value){
    if(value??false)
      state.filters["typology"]!.fieldValue = 'Azienda';
    else
      state.filters["typology"]!.fieldValue = null;
    emit(state.assign(isCompany: value ?? false));
  }
  setIsPrivate(bool? value){
    if(value??false)
      state.filters["typology"]!.fieldValue = 'Privato';
    else
      state.filters["typology"]!.fieldValue = null;
    emit(state.assign(isPrivate: value ?? false));
  }

  void forceRefresh() {
    emit(state.assign(status: _filterStatus.loading));
    emit(state.assign(status: _filterStatus.normal));
  }

  void clearFilters(){
    Map<String, FilterWrapper> filters = Map.of(state.filters);
    initFilters();
    if(filters.toString() == state.filters.toString()) showFiltersBox();
    notifyFiltersChanged(false);
  }

  void notifyFiltersChanged([bool filtersBoxSave = false]){
    if(filtersBoxSave && formKey.currentState!.validate()){
      formKey.currentState!.save();
      emit(state.assign(filtersBoxVisibile: false));
    }
    callbackFiltersChanged(state.filters);
  }
}
