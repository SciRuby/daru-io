RSpec.describe Daru::IO::Importers::RDS do
  subject { described_class.new().read(path) }

  context 'reads data from bc_sites RDS file' do
    let(:path) { 'spec/fixtures/rds/bc_sites.rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 25,
      nrows: 1113,
      index: (0..1112).to_a,
      order: %i[
        area description epa_reach format_version latitude location location_code location_type
        longitude name psc_basin psc_region record_code record_origin region reporting_agency
        rmis_basin rmis_latitude rmis_longitude rmis_region sector state_or_province sub_location
        submission_date water_type
      ]
  end

  context 'reads data from chicago RDS file' do
    let(:path) { 'spec/fixtures/rds/chicago.rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 8,
      nrows: 6940,
      index: (0..6939).to_a,
      order: %i[
        city date dptp no2tmean2 o3tmean2 pm10tmean2 pm25tmean2 tmpd
      ]
  end

  context 'reads data from healthexp RDS file' do
    let(:path) { 'spec/fixtures/rds/healthexp.Rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 6,
      nrows: 3030,
      index: (0..3029).to_a,
      order: %i[
        Country Health.Expenditure Life.Expectancy Population Region Year
      ]
  end

  context 'reads data from heights RDS file' do
    let(:path) { 'spec/fixtures/rds/heights.RDS' }

    it_behaves_like 'exact daru dataframe',
      ncols: 10,
      nrows: 3988,
      index: (0..3987).to_a,
      order: %i[
        asvab bdate education height id income race sat_math sex weight
      ]
  end

  context 'reads data from maacs_env RDS file' do
    let(:path) { 'spec/fixtures/rds/maacs_env.rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 27,
      nrows: 750,
      index: (0..749).to_a,
      order: %i[
        MxNum VisitNum airCanF airFelD airmus airnic coarse duBdRmBlaG duBdRmCanF duBdRmDerF duBdRmFelD
        duBdRmMusM duBdRmWeight duBedBlaG duBedCanF duBedDerF duBedFelD duBedMusM duBedWeight duKitchBlaG
        duKitchCanF duKitchDerF duKitchFelD duKitchMusM duKitchWeight no2 pm25
      ]
  end

  context 'reads data from RPPdataConverted RDS file' do
    let(:path) { 'spec/fixtures/rds/RPPdataConverted.rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 138,
      nrows: 168,
      index: (0..167).to_a,
      order: %i[
        1st.author.O 1st.author.R 80.power 90.power 95.power Actual.Power.O Analysis.completion.date.R
        Area.of.expertise.R Authors.O Calculated.P.value.O Citation.Count.1st.author.O
        Citation.count.1st.author.R Citation.count.paper.O Citation.count.senior.author.O
        Citation.count.senior.author.R Citations.R Coder.s.email.R Collect.materials.from.authors
        Completion.R Contact.Researcher.R Current.position.R Data.collection.quality.R Degree.R
        Description.of.effect.O Descriptors.O Differences.R Difficulty.of.implimentation.R Direction.R
        Discipline.O Domain.expertise.R Dummy Effect.Size.R Effect.similarity.R Effect.size.O
        Exciting.result.O Feasibility.O Findings.similarity.R Implementation.quality.R
        Institution.1st.author.O Institution.1st.author.R Institution.prestige.1st.author.O
        Institution.prestige.1st.author.R Institution.prestige.senior.author.O
        Institution.prestige.senior.author.R Institution.senior.author.O Institution.senior.author.R
        Internal.conceptual.replications.O Internal.direct.replications.O Issue.O Journal.O Local.ID
        Meta.analysis.significant Meta.analytic.estimate.Fz Method.expertise.R
        Methodology.expertise.required.O N.O N.R Notes.R Number.of.Authors.O Number.of.Authors.R
        Number.of.Research.sites.R Number.of.Studies.O Number.of.research.sites.O O.within.CI.R
        OSC.reviewer.O OSC.reviewer.R Opportunity.for.expectancy.bias.O Opportunity.for.lack.of.diligence.O
        Original.Author.s.Assessment P.value.R Pages.O Peer.reviewed.articles.R Planned.Power
        Planned.Sample Power.R Project.URL Project.audit.complete.R R.check.location.R Replicate.R
        Replicated.study.number.R Replication.similarity.R Reported.P.value.O Secondary.R Secondary.data.O
        Secondary.data.R Senior.author.O Senior.author.R Status.R Study.Title.O Study.claim.date.R
        Successful.conceptual.replications.O Successful.direct.replications.O Surprise.of.outcome.R
        Surprising.result.O T.Comparison.effects.R.O T.N.O T.N.O.for.tables T.N.R T.N.R.for.tables
        T.O.larger T.Test.Comparison.R T.Test.Statistic.O T.Test.Statistic.R T.Test.value.O T.Test.value.R
        T.TestComparison.O T.df1.O T.df1.R T.df2.O T.df2.R T.p.comparison.O T.p.comparison.R T.pval.O
        T.pval.R T.pval.USE.O T.pval.USE.R T.pval.recalc.O T.pval.recalc.R T.r.O T.r.R T.sign.O.113
        T.sign.O.131 T.sign.R.125 T.sign.R.132 Tails.O Tails.R Test.statistic.O Test.statistic.R
        Total.publications.R Type.of.analysis.O.128 Type.of.analysis.O.56 Type.of.analysis.R.129
        Type.of.analysis.R.74 Type.of.effect.O Type.of.effect.R V130 Volume.O Year.of.highest.degree.R
      ]
  end
end
