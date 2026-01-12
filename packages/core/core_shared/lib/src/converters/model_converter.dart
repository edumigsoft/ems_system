abstract class ModelConverter<TModel, TDomain> {
  TDomain toDomain(TModel model);
  TModel fromDomain(TDomain domain);
}
