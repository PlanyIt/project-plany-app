export class CreateCategoryDto {
  readonly name: string;
  readonly description: string;
}

export class UpdateCategoryDto {
  readonly name?: string;
  readonly description?: string;
}
