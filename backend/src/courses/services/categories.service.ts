import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Category } from '../entities/category.entity';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectRepository(Category)
    private readonly categoryRepository: Repository<Category>
  ) {}

  async create(createCategoryDto: CreateCategoryDto): Promise<Category> {
    // Verificar que la categoría padre existe si se especifica
    if (createCategoryDto.parentId) {
      const parent = await this.categoryRepository.findOne({
        where: { id: createCategoryDto.parentId },
      });
      if (!parent) {
        throw new NotFoundException(
          `Categoría padre con ID ${createCategoryDto.parentId} no encontrada`
        );
      }
    }

    // Generar slug automáticamente
    const slug = this.generateSlug(createCategoryDto.name);

    // Verificar que el slug no existe
    const existingCategory = await this.categoryRepository.findOne({
      where: { slug },
    });
    if (existingCategory) {
      throw new BadRequestException(
        `Ya existe una categoría con el nombre "${createCategoryDto.name}"`
      );
    }

    const category = this.categoryRepository.create({
      ...createCategoryDto,
      slug,
    });

    return this.categoryRepository.save(category);
  }

  async findAll(): Promise<Category[]> {
    return this.categoryRepository.find({
      relations: ['parent', 'children', 'courses'],
      order: { sortOrder: 'ASC', name: 'ASC' },
    });
  }

  async findAllActive(): Promise<Category[]> {
    return this.categoryRepository.find({
      where: { isActive: true },
      relations: ['parent', 'children', 'courses'],
      order: { sortOrder: 'ASC', name: 'ASC' },
    });
  }

  async findOne(id: string): Promise<Category> {
    const category = await this.categoryRepository.findOne({
      where: { id },
      relations: ['parent', 'children', 'courses'],
    });

    if (!category) {
      throw new NotFoundException(`Categoría con ID ${id} no encontrada`);
    }

    return category;
  }

  async findBySlug(slug: string): Promise<Category> {
    const category = await this.categoryRepository.findOne({
      where: { slug, isActive: true },
      relations: ['parent', 'children', 'courses'],
    });

    if (!category) {
      throw new NotFoundException(`Categoría con slug "${slug}" no encontrada`);
    }

    return category;
  }

  async update(id: string, updateCategoryDto: UpdateCategoryDto): Promise<Category> {
    const category = await this.findOne(id);

    // Verificar que la categoría padre existe si se especifica
    if (updateCategoryDto.parentId) {
      if (updateCategoryDto.parentId === id) {
        throw new BadRequestException('Una categoría no puede ser padre de sí misma');
      }

      const parent = await this.categoryRepository.findOne({
        where: { id: updateCategoryDto.parentId },
      });
      if (!parent) {
        throw new NotFoundException(
          `Categoría padre con ID ${updateCategoryDto.parentId} no encontrada`
        );
      }
    }

    // Actualizar slug si cambió el nombre
    if (updateCategoryDto.name && updateCategoryDto.name !== category.name) {
      const newSlug = this.generateSlug(updateCategoryDto.name);
      const existingCategory = await this.categoryRepository.findOne({
        where: { slug: newSlug },
      });
      if (existingCategory && existingCategory.id !== id) {
        throw new BadRequestException(
          `Ya existe una categoría con el nombre "${updateCategoryDto.name}"`
        );
      }
      category.slug = newSlug;
    }

    Object.assign(category, updateCategoryDto);
    return this.categoryRepository.save(category);
  }

  async remove(id: string): Promise<void> {
    const category = await this.findOne(id);

    // Verificar que no tenga cursos asociados
    const coursesCount = await this.categoryRepository
      .createQueryBuilder('category')
      .leftJoin('category.courses', 'course')
      .where('category.id = :id', { id })
      .getCount();

    if (coursesCount > 0) {
      throw new BadRequestException(
        'No se puede eliminar una categoría que tiene cursos asociados'
      );
    }

    // Verificar que no tenga subcategorías
    const childrenCount = await this.categoryRepository.count({
      where: { parentId: id },
    });

    if (childrenCount > 0) {
      throw new BadRequestException('No se puede eliminar una categoría que tiene subcategorías');
    }

    await this.categoryRepository.remove(category);
  }

  async getHierarchy(): Promise<Category[]> {
    // Obtener solo categorías padre (sin parentId)
    const parentCategories = await this.categoryRepository.find({
      where: { parentId: null, isActive: true },
      relations: ['children', 'courses'],
      order: { sortOrder: 'ASC', name: 'ASC' },
    });

    // Ordenar recursivamente las subcategorías
    for (const parent of parentCategories) {
      if (parent.children) {
        parent.children.sort((a, b) => {
          if (a.sortOrder !== b.sortOrder) {
            return a.sortOrder - b.sortOrder;
          }
          return a.name.localeCompare(b.name);
        });
      }
    }

    return parentCategories;
  }

  async getCategoryStats(id: string): Promise<{
    coursesCount: number;
    studentsCount: number;
    avgRating: number;
  }> {
    const result = await this.categoryRepository
      .createQueryBuilder('category')
      .leftJoin('category.courses', 'course')
      .leftJoin('course.enrollments', 'enrollment')
      .leftJoin('course.reviews', 'review')
      .select([
        'COUNT(DISTINCT course.id) as coursesCount',
        'COUNT(DISTINCT enrollment.userId) as studentsCount',
        'COALESCE(AVG(review.rating), 0) as avgRating',
      ])
      .where('category.id = :id', { id })
      .getRawOne();

    return {
      coursesCount: parseInt(result.coursesCount) || 0,
      studentsCount: parseInt(result.studentsCount) || 0,
      avgRating: parseFloat(result.avgRating) || 0,
    };
  }

  private generateSlug(name: string): string {
    return name
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // Remover acentos
      .replace(/[^a-z0-9\s-]/g, '') // Remover caracteres especiales
      .replace(/\s+/g, '-') // Reemplazar espacios con guiones
      .replace(/-+/g, '-') // Remover guiones duplicados
      .trim();
  }
}
